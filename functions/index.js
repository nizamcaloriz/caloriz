/**
 * Firebase Cloud Function (2nd gen) — Gemini API Proxy for Caloriz
 * -------------------------------------------------------------------
 * Replaces the Flutter app's DIRECT Gemini API call with a secure
 * server-side call. The prompt, generation config, and the exact raw
 * response text format are preserved 1:1 with the existing
 * `_getCaloriePrompt()` / `scanFood()` logic in ai_service.dart, so
 * the Flutter-side JSON parsing does NOT need to change.
 *
 * Flutter app --> analyzeFood (this function) --> Gemini API --> Flutter app
 *
 * SETUP
 * -----
 * 1. cd functions
 * 2. npm install
 * 3. firebase functions:secrets:set GEMINI_API_KEY
 *    (paste your real Gemini API key when prompted)
 * 4. firebase deploy --only functions:analyzeFood
 *
 * Recommended follow-up (separate task): enable Firebase App Check for
 * your Android/iOS apps, then set `enforceAppCheck: true` below.
 */

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { GoogleGenAI, Type } = require("@google/genai");
const { initializeApp, getApps, getApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

let db;
function getDb() {
  if (!db) {
    const adminApp = getApps().some((a) => a.name === "[DEFAULT]")
      ? getApp()
      : initializeApp();
    db = getFirestore(adminApp);
  }
  return db;
}

const geminiApiKey = defineSecret("GEMINI_API_KEY");

const PRIMARY_MODEL = "gemini-2.5-flash-lite";
const BACKUP_MODEL = "gemini-3.1-flash-lite";

// ---- Validation / abuse-prevention config ----
const MAX_IMAGE_BYTES = 8 * 1024 * 1024; // ~8MB raw image (base64 ~33% larger on the wire)
const ALLOWED_MIME_TYPES = new Set(["image/jpeg", "image/png", "image/webp"]);
const RATE_LIMIT_MAX_REQUESTS = 30; // per user
const RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000; // 1 hour

/**
 * EXACT same prompt as the Flutter app's `_getCaloriePrompt()`.
 * `language` is passed from the client (it already knows the app's
 * current language via LanguageController) — nothing else about the
 * prompt is client-controlled.
 */
function buildCaloriePrompt(language) {
  const lang = language && typeof language === "string" ? language : "English";
  return `Analyze the food in the image and return ONLY a JSON response (no markdown, no code blocks, just pure JSON).

IMPORTANT: Detect ALL distinct food items visible in the image. If there are multiple items (e.g., Rice, Dal, Salad), list them separately with their estimated quantities.
Estimate the ACTUAL QUANTITY of each item visible in the image.

IMPORTANT: The "foodName" value for each item MUST be written in ${lang} language. Do NOT use English for food names unless the app language is English.

Return ONLY valid JSON in this exact format:
{
  "items": [
    {
      "foodName": "specific food name in ${lang}",
      "servingSize": "estimated weight in grams (e.g., 180g)",
      "calories": number,
      "protein": grams,
      "carbs": grams,
      "fats": grams,
      "fiber": grams,
      "sugar": grams,
      "sodium": milligrams,
      "saturatedFat": grams
    }
  ],
  "confidence": decimal between 0.5 and 1.0
}

IMPORTANT: servingSize MUST be in grams format like "180g". Calculate all nutrition values for this estimated weight, NOT per 100g.
Return ONLY the JSON object, nothing else.`;
}

/**
 * Structured output schema mirroring the prompt's JSON shape exactly
 * (same fields the Flutter app already parses: foodName, servingSize,
 * calories, protein, carbs, fats, fiber, sugar, sodium, saturatedFat,
 * plus top-level confidence). This makes Gemini's JSON output more
 * reliable without changing what fields exist.
 */
const RESPONSE_SCHEMA = {
  type: Type.OBJECT,
  properties: {
    items: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          foodName: { type: Type.STRING },
          servingSize: { type: Type.STRING },
          calories: { type: Type.NUMBER },
          protein: { type: Type.NUMBER },
          carbs: { type: Type.NUMBER },
          fats: { type: Type.NUMBER },
          fiber: { type: Type.NUMBER },
          sugar: { type: Type.NUMBER },
          sodium: { type: Type.NUMBER },
          saturatedFat: { type: Type.NUMBER },
        },
        required: [
          "foodName",
          "servingSize",
          "calories",
          "protein",
          "carbs",
          "fats",
          "fiber",
          "sugar",
          "sodium",
          "saturatedFat",
        ],
      },
    },
    confidence: { type: Type.NUMBER },
  },
  required: ["items", "confidence"],
};

/** Same generation config values the app already used. */
const GENERATION_CONFIG = {
  temperature: 0.2,
  maxOutputTokens: 1024,
  topP: 0.95,
  topK: 40,
  responseMimeType: "application/json",
  responseSchema: RESPONSE_SCHEMA,
};

/** Returns true if the error looks transient/retryable. */
function isRetryableError(err) {
  const status = err?.status ?? err?.code ?? err?.httpStatus;
  const message = (err?.message || "").toLowerCase();
  if ([429, 500, 502, 503, 504].includes(Number(status))) return true;
  if (
    message.includes("overloaded") ||
    message.includes("timeout") ||
    message.includes("unavailable") ||
    message.includes("rate limit") ||
    message.includes("deadline")
  ) {
    return true;
  }
  return false;
}

/** Simple per-user rate limit using Firestore (sliding window). */
async function checkRateLimit(uid) {
  try {
    const firestore = getDb();
    const ref = firestore.collection("scan_rate_limits").doc(uid);
    const now = Date.now();

    await firestore.runTransaction(async (tx) => {
      const doc = await tx.get(ref);
      const data = doc.exists ? doc.data() : { requests: [] };
      const recent = (data.requests || []).filter(
        (ts) => now - ts < RATE_LIMIT_WINDOW_MS
      );

      if (recent.length >= RATE_LIMIT_MAX_REQUESTS) {
        throw new HttpsError(
          "resource-exhausted",
          "Scan limit reached. Please try again later."
        );
      }

      recent.push(now);
      tx.set(ref, { requests: recent, updatedAt: FieldValue.serverTimestamp() });
    });
  } catch (err) {
    if (err instanceof HttpsError) throw err;
    console.warn("Rate limit check failed (allowing scan):", err.message);
  }
}

exports.analyzeFood = onCall(
  {
    secrets: [geminiApiKey],
    region: "us-central1",
    memory: "512MiB",
    timeoutSeconds: 60,
    // enforceAppCheck: true, // enable once App Check is configured in the app
  },
  async (request) => {
    // ---- Auth check (app already requires email/Apple ID login) ----
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to use food scanning."
      );
    }
    const uid = request.auth.uid;

    // ---- Rate limit ----
    await checkRateLimit(uid);

    // ---- Input validation ----
    const { imageBase64, mimeType, language } = request.data || {};

    if (!imageBase64 || typeof imageBase64 !== "string") {
      throw new HttpsError("invalid-argument", "imageBase64 is required.");
    }
    const resolvedMimeType = mimeType || "image/jpeg";
    if (!ALLOWED_MIME_TYPES.has(resolvedMimeType)) {
      throw new HttpsError(
        "invalid-argument",
        `mimeType must be one of: ${[...ALLOWED_MIME_TYPES].join(", ")}`
      );
    }
    const approxBytes = Math.ceil((imageBase64.length * 3) / 4);
    if (approxBytes > MAX_IMAGE_BYTES) {
      throw new HttpsError(
        "invalid-argument",
        "Image is too large. Please use a smaller photo."
      );
    }

    const ai = new GoogleGenAI({ apiKey: geminiApiKey.value() });

    const prompt = buildCaloriePrompt(language);
    const contents = [
      {
        role: "user",
        parts: [
          { text: prompt },
          { inlineData: { data: imageBase64, mimeType: resolvedMimeType } },
        ],
      },
    ];

    async function callModel(modelName) {
      return ai.models.generateContent({
        model: modelName,
        contents,
        config: GENERATION_CONFIG,
      });
    }

    // ---- Try PRIMARY, fall back to BACKUP ----
    try {
      const result = await callModel(PRIMARY_MODEL);
      return { modelUsed: PRIMARY_MODEL, text: result.text ?? "{}" };
    } catch (primaryError) {
      console.error("Primary model error", {
        uid,
        model: PRIMARY_MODEL,
        message: primaryError.message,
        status: primaryError.status,
      });

      try {
        const result = await callModel(BACKUP_MODEL);
        return { modelUsed: BACKUP_MODEL, text: result.text ?? "{}" };
      } catch (backupError) {
        console.error("Backup model error", {
          uid,
          model: BACKUP_MODEL,
          message: backupError.message,
          status: backupError.status,
        });
        const errDetail = primaryError.message || backupError.message || "Food analysis failed.";
        throw new HttpsError(
          "internal",
          `Food analysis failed: ${errDetail}`
        );
      }
    }
  }
);
