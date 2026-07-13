import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../../../core/services/auth_service.dart';
import '../../../core/services/iap_service.dart';
import '../../../core/services/subscription_pricing_helper.dart';

class PartnerProgramController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // IAP Service and centralized pricing helper
  late final IAPService _iapService;
  late final SubscriptionPricingHelper _pricing;
  bool _iapInitialized = false;

  // Observable variables
  final RxString referralCode = ''.obs;
  final RxInt totalReferrals = 0.obs;
  final RxInt activeSubscribers = 0.obs;
  final RxDouble monthlyEarnings = 0.0.obs;
  final RxDouble totalEarnings = 0.0.obs;
  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> referredUsers =
      <Map<String, dynamic>>[].obs;

  // Wallet management
  final RxDouble walletBalance = 0.0.obs;
  final RxDouble pendingEarnings = 0.0.obs;
  final RxString paymentMethod = ''.obs; // 'bank', 'upi', 'paypal'
  final RxString paymentDetails = ''.obs;
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;

  // Commission rates: India 30%, International 50%
  static const double indiaCommissionRate = 0.30;
  static const double intlCommissionRate = 0.50;

  // Active commission rate based on user's store region.
  // Region is determined ONLY by the store product's currencyCode (INR = India).
  // Never use IP, locale, or timezone.
  double get activeCommissionRate =>
      isIndia ? indiaCommissionRate : intlCommissionRate;

  // Minimum withdrawal threshold, in local currency units.
  // ₹1000 for INR accounts, $10 / £10 / €10 for others.
  double get minimumWithdrawal => isIndia ? 1000.0 : 10.0;

  // Region flag — derived from the store product's currencyCode only.
  // The subscription product itself is the source of truth for user region.
  bool get isIndia => currencyCode == 'INR';

  // Currency code from the live store product (ISO 4217, e.g. "INR", "USD").
  String get currencyCode =>
      _iapInitialized ? _pricing.getCurrencyCode() : '';

  // Currency symbol derived from currencyCode — never hardcoded directly.
  String get currencySymbol {
    switch (currencyCode) {
      case 'INR': return '₹';
      case 'USD': return '\$';
      case 'GBP': return '£';
      case 'EUR': return '€';
      case 'CAD': return 'CA\$';
      case 'AUD': return 'A\$';
      default: return currencyCode.isNotEmpty ? '$currencyCode ' : '\$';
    }
  }

  // FIX: Amounts are already stored in local currency (INR/USD) — no conversion needed
  String formatCurrency(double amount) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<IAPService>()) {
      _iapService = Get.find<IAPService>();
      _pricing = SubscriptionPricingHelper(_iapService);
      _iapInitialized = true;
      _ensureProductsLoaded();
    }
    _loadPartnerData();
  }

  /// Ensure IAP products are loaded so pricing is available.
  Future<void> _ensureProductsLoaded() async {
    try {
      if (_iapService.products.isEmpty) {
        await _iapService.loadProducts();
      }
      _pricing.logPricingDetails();
      print('💱 [Partner Program] currencyCode: $currencyCode | isIndia: $isIndia | symbol: $currencySymbol');
    } catch (e) {
      print('⚠️ [Partner Program] Error loading products for pricing: $e');
    }
  }

  Future<void> _loadPartnerData() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUserId.value;

      print('📱 [Partner Program] Loading data for userId: $userId');

      if (userId != null) {
        // Load or create referral code
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          print('📋 [Partner Program] User doc exists, data: $data');

          // Get or generate referral code - also check for empty string
          if (data.containsKey('referralCode') &&
              data['referralCode'] != null &&
              data['referralCode'].toString().isNotEmpty) {
            referralCode.value = data['referralCode'];
            print(
              '✅ [Partner Program] Referral code loaded: ${referralCode.value}',
            );
          } else {
            // Generate new referral code
            print(
              '⚠️ [Partner Program] No referral code found, generating new one...',
            );
            referralCode.value = await _generateReferralCode(
              userId,
              data['name'] ?? _authService.currentUserName.value ?? 'User',
            );
            print(
              '✅ [Partner Program] New referral code generated: ${referralCode.value}',
            );
          }

          // Load referral statistics
          await _loadReferralStats(userId);

          // Load wallet data
          await _loadWalletData(userId);
        } else {
          // User document doesn't exist - create it with referral code
          print('⚠️ [Partner Program] User doc does not exist, creating...');
          referralCode.value = await _generateReferralCode(
            userId,
            _authService.currentUserName.value ?? 'User',
          );
          print(
            '✅ [Partner Program] New referral code generated: ${referralCode.value}',
          );
        }
      } else {
        print('❌ [Partner Program] User ID is null!');
      }
    } catch (e) {
      print('❌ [Partner Program] Error loading partner data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> _generateReferralCode(String userId, String name) async {
    // Generate unique referral code (e.g., JO1234)
    final random = Random();
    String code;
    bool isUnique = false;

    // Get first 2 letters of name (or fallback)
    String prefix = 'CA';
    if (name.isNotEmpty) {
      final cleanName = name.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
      if (cleanName.length >= 2) {
        prefix = cleanName.substring(0, 2);
      } else if (cleanName.length == 1) {
        prefix = '${cleanName}X';
      }
    }

    do {
      // Generate 4 random digits
      String digits = '';
      for (int i = 0; i < 4; i++) {
        digits += random.nextInt(10).toString();
      }

      code = '$prefix$digits';

      // Check if code already exists
      final existingCode = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: code)
          .get();

      isUnique = existingCode.docs.isEmpty;
    } while (!isUnique);

    // Save the code to user document
    await _firestore.collection('users').doc(userId).set({
      'referralCode': code,
      'referralCreatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return code;
  }

  Future<void> _loadReferralStats(String userId) async {
    try {
      // Get all users referred by this user
      final referralsSnapshot = await _firestore
          .collection('referrals')
          .where('referrerId', isEqualTo: userId)
          .get();

      totalReferrals.value = referralsSnapshot.docs.length;
      referredUsers.clear();

      double monthlyTotal = 0.0;
      double lifetimeTotal = 0.0;
      int activeCount = 0;

      for (var doc in referralsSnapshot.docs) {
        final data = doc.data();
        final referredUserId = data['referredUserId'];
        final referralStatus = data['status'] ?? 'pending';
        final commissionFromDoc = (data['commissionAmount'] ?? 0.0).toDouble();

        // Get referred user's info
        final userDoc = await _firestore
            .collection('users')
            .doc(referredUserId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          // FIX: Use 'isPremium' not 'isSubscribed'
          final isSubscribed = userData['isPremium'] ?? false;
          // Referral is 'active' if status is completed OR user isPremium
          final isActive = referralStatus == 'completed' || isSubscribed;

          if (isActive) {
            activeCount++;

            // Use actual store rawPrice for commission calculation — never hardcode.
            // commissionFromDoc is what was stored at purchase time (already correct).
            // If doc has no commission (legacy), fall back to current store monthly price.
            double userMonthlyCommission = commissionFromDoc > 0
                ? commissionFromDoc
                : (_iapInitialized
                    ? _pricing.getMonthlyRawPrice() * activeCommissionRate
                    : 0.0);

            monthlyTotal += userMonthlyCommission;
            lifetimeTotal += userMonthlyCommission;

            referredUsers.add({
              'name': userData['name'] ?? 'User',
              'joinedDate': data['referredAt'],
              'isActive': true,
              'monthlyCommission': userMonthlyCommission,
              'totalEarned': userMonthlyCommission,
            });
          } else {
            referredUsers.add({
              'name': userData['name'] ?? 'User',
              'joinedDate': data['referredAt'],
              'isActive': false,
              'monthlyCommission': 0.0,
              'totalEarned': 0.0,
            });
          }
        }
      }

      activeSubscribers.value = activeCount;
      monthlyEarnings.value = monthlyTotal;
      totalEarnings.value = lifetimeTotal;
    } catch (e) {
      print('Error loading referral stats: $e');
    }
  }

  double calculatePotentialEarnings(int referralCount) {
    // Use actual store rawPrice as base — localized automatically by the store.
    final basePrice = _iapInitialized
        ? _pricing.getMonthlyRawPrice()
        : 0.0;
    print('💰 [Partner Program] Potential earnings base price: $basePrice $currencyCode');
    return referralCount * basePrice * activeCommissionRate;
  }

  void shareReferralCode() {
    final message =
        '''
🌟 Join Caloriz - Your Personal Nutrition Assistant!

Use my referral code: ${referralCode.value}

Get started on your health journey and we both benefit!

Download now: [App Link]
''';

    Share.share(message);
  }

  Future<void> shareViaWhatsApp() async {
    final message =
        '🌟 Join Caloriz with my referral code: ${referralCode.value}\n\nStart tracking your nutrition and reach your goals!';
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/?text=$encodedMessage';

    final uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to regular share
      Share.share(message);
    }
  }

  Future<void> refreshData() async {
    await _loadPartnerData();
  }

  Future<void> _loadWalletData(String userId) async {
    try {
      // FIX: Read wallet balance from users doc (walletBalance / totalEarned fields)
      // IAPService writes commission to users/{referrerId}.walletBalance
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        walletBalance.value = (data['walletBalance'] ?? 0.0).toDouble();
        pendingEarnings.value = (data['pendingEarnings'] ?? 0.0).toDouble();
        paymentMethod.value = data['paymentMethod'] ?? '';
        paymentDetails.value = data['paymentDetails'] ?? '';
      } else {
        walletBalance.value = totalEarnings.value;
        pendingEarnings.value = 0.0;
      }

      // Load transaction history from wallets subcollection or transactions collection
      try {
        final transactionsSnapshot = await _firestore
            .collection('transactions')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .limit(20)
            .get();

        transactions.value = transactionsSnapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      } catch (e) {
        print('Transactions load error (index may be missing): $e');
      }
    } catch (e) {
      print('Error loading wallet data: $e');
    }
  }

  Future<void> requestWithdrawal() async {
    final userId = _authService.currentUserId.value;
    if (userId == null) return;

    // Check minimum withdrawal
    if (walletBalance.value < minimumWithdrawal) {
      Get.snackbar(
        'Insufficient Balance',
        'Minimum withdrawal amount is ${formatCurrency(minimumWithdrawal)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Check payment method
    if (paymentMethod.value.isEmpty) {
      Get.snackbar(
        'Payment Method Required',
        'Please set up your payment method first',
        snackPosition: SnackPosition.BOTTOM,
      );
      showPaymentMethodDialog();
      return;
    }

    try {
      isLoading.value = true;

      // Create withdrawal request
      await _firestore.collection('withdrawals').add({
        'userId': userId,
        'amount': walletBalance.value,
        'currencySymbol': currencySymbol,
        'paymentMethod': paymentMethod.value,
        'paymentDetails': paymentDetails.value,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      // Move balance to pending in USERS collection (Source of Truth)
      await _firestore.collection('users').doc(userId).update({
        'walletBalance': 0.0,
        'pendingEarnings': FieldValue.increment(walletBalance.value),
        'paymentMethod': paymentMethod.value,
        'paymentDetails': paymentDetails.value,
        'lastWithdrawalAt': FieldValue.serverTimestamp(),
      });

      // Keep redundant record in wallets/userId for backup/audit if needed
      await _firestore.collection('wallets').doc(userId).set({
        'balance': 0.0,
        'pending': walletBalance.value,
        'paymentMethod': paymentMethod.value,
        'paymentDetails': paymentDetails.value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Create transaction record
      await _firestore.collection('transactions').add({
        'userId': userId,
        'type': 'withdrawal',
        'amount': walletBalance.value,
        'currencySymbol': currencySymbol,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      pendingEarnings.value = walletBalance.value;
      walletBalance.value = 0.0;

      Get.snackbar(
        'Withdrawal Requested',
        'Your withdrawal request has been submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00E3CC),
        colorText: Colors.black,
      );

      await _loadWalletData(userId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process withdrawal request',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showPaymentMethodDialog() {
    // Auto-detect method based on region
    if (isIndia) {
      _showUpiDialog();
    } else {
      _showPaypalDialog();
    }
  }

  void _showUpiDialog() {
    final textController = TextEditingController(text: paymentDetails.value);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.payment, color: Color(0xFF00A89E)),
            SizedBox(width: 10),
            Text('UPI Details'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your UPI ID to receive commissions.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'UPI ID',
                hintText: 'yourname@upi',
                prefixIcon: const Icon(Icons.alternate_email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A89E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final upiId = textController.text.trim();
              if (upiId.isEmpty) return;
              Get.back();
              await _savePaymentDetails('upi', upiId);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPaypalDialog() {
    final textController = TextEditingController(text: paymentDetails.value);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.paypal, color: Color(0xFF003087)),
            SizedBox(width: 10),
            Text('PayPal Details'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your PayPal email to receive commissions.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'PayPal Email',
                hintText: 'you@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003087),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final email = textController.text.trim();
              if (email.isEmpty) return;
              Get.back();
              await _savePaymentDetails('paypal', email);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePaymentDetails(String method, String details) async {
    final userId = _authService.currentUserId.value;
    if (userId == null) return;

    try {
      // Save to users doc (same place as wallet balance)
      await _firestore.collection('users').doc(userId).update({
        'paymentMethod': method,
        'paymentDetails': details,
      });

      paymentMethod.value = method;
      paymentDetails.value = details;

      Get.snackbar(
        'Saved ✅',
        method == 'upi'
            ? 'UPI ID saved: $details'
            : 'PayPal email saved: $details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00A89E),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not save payment details',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
