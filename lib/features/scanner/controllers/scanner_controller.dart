import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/barcode_scanner_page.dart';
import '../views/food_details_page.dart';
import '../views/ai_food_details_page.dart';
import '../views/food_analysis_progress_dialog.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/auth_service.dart';

class ScannerController extends GetxController {
  CameraController? cameraController;
  final selectedMode = 0.obs; // 0: Food Scan, 1: Bar Code, 2: Manual Click
  final isInitialized = false.obs;
  final isProcessing = false.obs;
  final ImagePicker _picker = ImagePicker();
  final AIService _aiService = Get.find<AIService>();
  final AdService _adService = Get.find<AdService>();
  final AuthService _authService = Get.find<AuthService>();

  // Scan tracking - Daily ad-based scan system
  final RxInt remainingScans =
      0.obs; // Start with 0, user must watch ad for 1 daily scan
  final RxString lastScanDate = ''.obs; // Track last scan date for daily reset
  final RxBool hasClaimedDailyAdScan =
      false.obs; // Track if user claimed today's ad scan
  final RxBool isPremium = false.obs; // Always false for now (subscription disabled)

  @override
  void onInit() {
    super.onInit();
    print('\n📱 [SCANNER CONTROLLER INIT]');
    print('🔧 Initializing camera...');
    initializeCamera();
    print('📊 Loading scan count...');
    _loadScanCount();
    print('✅ [Subscription check ENABLED]');
    isPremium.bindStream(_authService.isPremium.stream);
    isPremium.value = _authService.isPremium.value;
    print('✅ Initialization complete\n');
  }

  Future<void> _loadScanCount() async {
    try {
      print('📥 _loadScanCount: Loading scan data...');
      final userId = _authService.currentUserId.value;
      print('👤 User ID: $userId');

      final todayDate = DateTime.now().toIso8601String().split(
        'T',
      )[0]; // YYYY-MM-DD
      print('📅 Today: $todayDate');

      if (userId != null) {
        print('🔥 Loading from Firebase...');
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          final savedDate = (data['lastScanDate'] as String?) ?? '';
          print('📋 Saved lastScanDate: $savedDate');
          print('📋 Saved remainingScans: ${data['remainingScans']}');
          print(
            '📋 Saved hasClaimedDailyAdScan: ${data['hasClaimedDailyAdScan']}',
          );

          // Check if it's a new day - reset to 0 scans and allow ad claim again
          if (savedDate != todayDate) {
            print(
              '🌅 New day detected! Resetting - 0 scans, ad claim available',
            );
            remainingScans.value = 0;
            hasClaimedDailyAdScan.value = false;
            lastScanDate.value = todayDate;
            await _saveScanCount();
          } else {
            print('📌 Same day - keeping existing scan count');
            remainingScans.value = (data['remainingScans'] as int?) ?? 0;
            hasClaimedDailyAdScan.value =
                (data['hasClaimedDailyAdScan'] as bool?) ?? false;
            lastScanDate.value = savedDate;
          }
        } else {
          print('⚠️ No Firebase document - initializing with 0 scans');
          remainingScans.value = 0;
          hasClaimedDailyAdScan.value = false;
          lastScanDate.value = todayDate;
          await _saveScanCount();
        }
      } else {
        print('⚠️ No user ID - using local storage');
        final prefs = await SharedPreferences.getInstance();
        final savedDate = prefs.getString('last_scan_date') ?? '';

        if (savedDate != todayDate) {
          print('🌅 New day detected! Resetting - 0 scans, ad claim available');
          remainingScans.value = 0;
          hasClaimedDailyAdScan.value = false;
          lastScanDate.value = todayDate;
          await _saveScanCount();
        } else {
          remainingScans.value = prefs.getInt('remaining_scans') ?? 0;
          hasClaimedDailyAdScan.value =
              prefs.getBool('has_claimed_daily_ad_scan') ?? false;
          lastScanDate.value = savedDate;
        }
      }
      print('✅ Remaining scans: ${remainingScans.value}');
      print('✅ Scan count loaded\n');
    } catch (e) {
      print('❌ Error loading scan count: $e\n');
      remainingScans.value = 0;
      hasClaimedDailyAdScan.value = false;
      lastScanDate.value = DateTime.now().toIso8601String().split('T')[0];
    }
  }

  Future<void> _saveScanCount() async {
    try {
      final userId = _authService.currentUserId.value;
      if (userId != null) {
        // Save to Firebase
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'remainingScans': remainingScans.value,
          'lastScanDate': lastScanDate.value,
          'hasClaimedDailyAdScan': hasClaimedDailyAdScan.value,
          'lastScanUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Also save locally as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('remaining_scans', remainingScans.value);
      await prefs.setString('last_scan_date', lastScanDate.value);
      await prefs.setBool(
        'has_claimed_daily_ad_scan',
        hasClaimedDailyAdScan.value,
      );
    } catch (e) {
      print('Error saving scan count: $e');
    }
  }



  void addScanFromAd() {
    // Mark that user has claimed their daily ad scan
    hasClaimedDailyAdScan.value = true;
    remainingScans.value += 1;
    _saveScanCount();
    Get.snackbar(
      'Scan Unlocked! 🎉',
      'You got your daily scan from watching ad!',
      backgroundColor: const Color(0xFF00E3CC),
      colorText: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }

  bool _checkScanAvailability() {
    print('\n🔐 [CHECK SCAN AVAILABILITY]');
    print('👤 isPremium: ${isPremium.value}');
    print('📊 remainingScans: ${remainingScans.value}');
    print('📅 lastScanDate: ${lastScanDate.value}');

    // Premium users have unlimited scans
    if (isPremium.value) {
      print('✅ Premium user - unlimited scans available');
      print('═══════════════════════════════════════════════════\n');
      return true;
    }

    // Check if free scans available
    if (remainingScans.value > 0) {
      print('✅ Free scans available: ${remainingScans.value}');
      print('═══════════════════════════════════════════════════\n');
      return true;
    }

    // No scans available - show options dialog
    print('❌ No scans available - showing limit dialog');
    print('═══════════════════════════════════════════════════\n');
    _showScanLimitDialog();
    return false;
  }

  void _showScanLimitDialog() {
    Get.dialog(
      _ScanLimitDialogWithCountdown(
        hasClaimedDailyAdScan: hasClaimedDailyAdScan.value,
        onWatchAd: () async {
          Get.back(); // Close dialog

          final success = await _adService.showRewardedAd(
            onRewarded: () {
              addScanFromAd();
            },
          );

          if (!success) {
            Get.snackbar(
              'Ad Not Ready',
              'Please try again in a moment',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        onGetPremium: () {
          Get.back(); // Close dialog
          Get.toNamed('/premium'); // Navigate to premium page
        },
      ),
      barrierDismissible: false,
    );
  }

  void _consumeScan() {
    if (!isPremium.value && remainingScans.value > 0) {
      remainingScans.value -= 1;
      _saveScanCount();
    }
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar('error'.tr, 'no_camera_found'.tr);
        return;
      }

      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isInitialized.value = true;
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_to_initialize_camera'.tr}: $e');
    }
  }

  void selectMode(int index) {
    selectedMode.value = index;
    // Automatically open gallery when Manual Click is selected
    if (index == 2) {
      pickImageFromGallery();
    }
  }

  Future<void> captureImage() async {
    print('\n═══════════════════════════════════════════════════');
    print('📷 [CAPTURE IMAGE] Capture initiated');

    // Check scan availability first
    if (!_checkScanAvailability()) {
      print('❌ Scan not available - cannot proceed');
      return;
    }

    // For Manual Click mode, open gallery
    if (selectedMode.value == 2) {
      print('📁 Mode: Manual Click - Opening gallery');
      pickImageFromGallery();
      return;
    }

    // For Bar Code mode, open barcode scanner
    if (selectedMode.value == 1) {
      print('🔍 Mode: Barcode Scan');
      openBarcodeScanner();
      return;
    }

    if (cameraController == null || !cameraController!.value.isInitialized) {
      print('❌ Camera not initialized');
      return;
    }

    if (isProcessing.value) {
      print('⏳ Already processing - ignoring this request');
      return;
    }

    isProcessing.value = true;
    print('📸 Mode: Food Scan - Taking picture...');

    try {
      final image = await cameraController!.takePicture();
      print('✅ Picture taken: ${image.path}');

      // Consume scan before processing
      _consumeScan();
      print('📊 Remaining scans: ${remainingScans.value}');

      // Food Scan mode - Process with AI
      await _processFoodImage(image.path);
    } catch (e) {
      print('❌ Capture error: $e');
      Get.snackbar(
        'Error',
        'Failed to capture image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
      print('═══════════════════════════════════════════════════\n');
    }
  }

  Future<void> pickImageFromGallery() async {
    // Check scan availability first
    if (!_checkScanAvailability()) {
      return;
    }

    try {
      isProcessing.value = true;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        // Consume scan before processing
        _consumeScan();

        // Process image with AI
        await _processFoodImage(image.path);
      } else {
        Get.snackbar(
          'Cancelled',
          'No image selected',
          backgroundColor: Colors.grey,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> openBarcodeScanner() async {
    // Check scan availability first
    if (!_checkScanAvailability()) {
      return;
    }

    try {
      // Navigate to barcode scanner page
      final barcode = await Get.to(() => const BarcodeScannerPage());

      if (barcode != null && barcode.toString().isNotEmpty) {
        isProcessing.value = true;

        // Consume scan before processing
        _consumeScan();

        await fetchProductFromOpenFoodFacts(barcode.toString());
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to scan barcode: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> fetchProductFromOpenFoodFacts(String barcode) async {
    try {
      final url =
          'https://world.openfoodfacts.org/api/v0/product/$barcode.json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1) {
          // Navigate to detailed food page
          Get.to(() => FoodDetailsPage(productData: data));
        } else {
          Get.snackbar(
            'Not Found',
            'Product not found in Open Food Facts database',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch product data',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch product: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _processFoodImage(String imagePath) async {
    // Show progress dialog
    final GlobalKey<FoodAnalysisProgressDialogState> progressKey =
        GlobalKey<FoodAnalysisProgressDialogState>();

    Get.dialog(
      FoodAnalysisProgressDialog(key: progressKey),
      barrierDismissible: false,
      barrierColor: Colors.black54,
    );

    try {
      print('\n🔔 [SCANNER CONTROLLER] _processFoodImage called');
      print('📸 Image path: $imagePath');

      print('⏳ Calling AIService.scanFood()...');
      // Use AI service to scan food
      final foodData = await _aiService.scanFood(imagePath);

      print('✅ AIService returned: $foodData');

      if (foodData.containsKey('error') && foodData['error'] == true) {
        print('❌ Error in AI response: ${foodData['errorMessage']}');
        throw Exception(foodData['errorMessage']);
      }

      // Complete progress to 100% then close
      progressKey.currentState?.completeAndClose();
      // Wait for the dialog close animation
      await Future.delayed(const Duration(milliseconds: 600));

      print('🚀 Navigating to AIFoodDetailsPage');
      // Navigate to AI food details page
      Get.to(() => AIFoodDetailsPage(foodData: foodData, imagePath: imagePath));
      print('✅ Navigation complete');
    } catch (e) {
      print('\n❌ [SCANNER CONTROLLER ERROR] Error: $e');
      print('📋 Stack trace: ${StackTrace.current}');

      // Close progress dialog if open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Show detailed error message
      String errorMessage = 'Failed to analyze food';
      if (e.toString().contains('GEMINI_API_KEY')) {
        errorMessage = 'API key not configured. Please check .env file';
      } else if (e.toString().contains('Image file not found')) {
        errorMessage = 'Image file not found. Please try again';
      } else if (e.toString().contains('Failed to analyze')) {
        errorMessage = 'AI could not analyze the image. Try a clearer photo';
      } else {
        errorMessage = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
      }

      print('⚠️ Error message to show: $errorMessage');

      Get.snackbar(
        'Analysis Failed',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}

// Countdown Dialog Widget for Scan Limit
class _ScanLimitDialogWithCountdown extends StatefulWidget {
  final bool hasClaimedDailyAdScan;
  final VoidCallback onWatchAd;
  final VoidCallback onGetPremium;

  const _ScanLimitDialogWithCountdown({
    required this.hasClaimedDailyAdScan,
    required this.onWatchAd,
    required this.onGetPremium,
  });

  @override
  State<_ScanLimitDialogWithCountdown> createState() =>
      _ScanLimitDialogWithCountdownState();
}

class _ScanLimitDialogWithCountdownState
    extends State<_ScanLimitDialogWithCountdown> {
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeRemaining();
    });
  }

  void _calculateTimeRemaining() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    setState(() {
      _timeRemaining = midnight.difference(now);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Different title based on whether user has used their scan or not claimed yet
    final String title = widget.hasClaimedDailyAdScan
        ? '🔒 Daily Limit Reached'
        : '🎬 Watch Ad for Free Scan';

    final String message = widget.hasClaimedDailyAdScan
        ? 'You\'ve used your daily scan!\n\nGet Premium for unlimited scans.'
        : 'Watch a short ad to unlock your daily free scan!';

    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Countdown Timer Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00E3CC).withOpacity(0.1),
                  const Color(0xFF00A89E).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00E3CC).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  widget.hasClaimedDailyAdScan
                      ? '⏰ Next ad scan available in'
                      : '⏰ Free scan resets in',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(_timeRemaining),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E3CC),
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'hours : minutes : seconds',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Show Watch Ad button only if user hasn't claimed daily scan yet
          if (!widget.hasClaimedDailyAdScan) ...[
            ElevatedButton.icon(
              onPressed: widget.onWatchAd,
              icon: const Icon(Icons.play_circle_outline, color: Colors.white),
              label: const Text(
                '▶ Watch Ad for 1 Free Scan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E3CC),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Or get unlimited scans:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
          ],

          // Get Premium Button - Always show
          ElevatedButton.icon(
            onPressed: widget.onGetPremium,
            icon: const Icon(Icons.star, color: Colors.white),
            label: Text(
              widget.hasClaimedDailyAdScan
                  ? '⭐ Get Premium (Unlimited Scans)'
                  : '⭐ Get Premium',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.hasClaimedDailyAdScan
                  ? const Color(0xFF00E3CC)
                  : Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Close button for convenience
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Close',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
