// Test file to verify Gemini API integration
// Run: flutter run test/gemini_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 Testing Gemini API Integration...\n');
  
  try {
    // Load .env file
    print('📂 Loading .env file...');
    await dotenv.load(fileName: ".env");
    print('✅ .env loaded successfully\n');
    
    // Get API key
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    print('🔑 API Key: ${apiKey?.substring(0, 20)}...\n');
    
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_gemini_api_key_here') {
      print('❌ ERROR: Invalid API key in .env file');
      print('Please add your actual Gemini API key to .env file\n');
      return;
    }
    
    // Initialize model
    print('🤖 Initializing Gemini model...');
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
    print('✅ Model initialized\n');
    
    // Test simple text generation
    print('📝 Testing text generation...');
    final prompt = 'Say "Hello from Gemini!" in JSON format: {"message": "..."}';
    final response = await model.generateContent([Content.text(prompt)]);
    print('Response: ${response.text}\n');
    
    print('✅ ✅ ✅ ALL TESTS PASSED! ✅ ✅ ✅');
    print('Your Gemini API is working correctly!\n');
    print('You can now use the Food Scanner in the app 🎉\n');
    
  } catch (e, stackTrace) {
    print('❌ ERROR: $e');
    print('Stack trace: $stackTrace\n');
    print('Please check:');
    print('1. .env file exists in project root');
    print('2. GEMINI_API_KEY is correctly set in .env');
    print('3. API key is valid (get from https://aistudio.google.com)');
    print('4. Internet connection is working\n');
  }
}
