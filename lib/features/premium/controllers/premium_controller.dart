import 'dart:io';
import 'package:get/get.dart';

import '../../../core/services/iap_service.dart';
import '../../../core/services/subscription_pricing_helper.dart';

/// Controls the premium/paywall screen.
///
/// Pricing is NEVER hardcoded here. All price text, raw prices, and currency
/// codes are fetched exclusively from the live store via [SubscriptionPricingHelper].
class PremiumController extends GetxController {
  final IAPService _iapService = Get.find<IAPService>();
  late final SubscriptionPricingHelper pricing;

  final RxBool isLoading = false.obs;
  final RxInt selectedPlan = 1.obs; // Default to yearly (best value)

  /// True once store products have been successfully loaded.
  final RxBool productsLoaded = false.obs;

  /// True if product loading failed and no products are available.
  final RxBool loadFailed = false.obs;

  @override
  void onInit() {
    super.onInit();
    pricing = SubscriptionPricingHelper(_iapService);
    _loadProducts();
  }

  // ─── Product IDs ────────────────────────────────────────────────────────

  String get monthlyProductId => IAPService.monthlySubscriptionId;
  String get yearlyProductId => IAPService.yearlySubscriptionId;

  // ─── Dynamic pricing from store — single source of truth ────────────────

  /// Monthly plan price text exactly as returned by the store (e.g. "₹297", "$9.99").
  String get monthlyPriceText => pricing.getMonthlyPriceText();

  /// Yearly plan price text exactly as returned by the store.
  String get yearlyPriceText => pricing.getYearlyPriceText();

  /// Currency code from the store product (e.g. "INR", "USD").
  String get currencyCode => pricing.getCurrencyCode();

  // ─── Plan definitions (prices are populated from store, never hardcoded) ─

  /// The currently selected plan product ID.
  String get selectedProductId =>
      selectedPlan.value == 0 ? monthlyProductId : yearlyProductId;

  // ─── Premium features list ───────────────────────────────────────────────

  final List<Map<String, dynamic>> features = [
    {
      'icon': '🔓',
      'title': 'Unlimited Scans',
      'description': 'Scan unlimited food items without watching ads',
    },
    {
      'icon': '📊',
      'title': 'Advanced Analytics',
      'description': 'Detailed nutrition tracking and insights',
    },
    {
      'icon': '🎯',
      'title': 'Custom Goals',
      'description': 'Set personalized nutrition targets',
    },
    {
      'icon': '📱',
      'title': 'No Ads',
      'description': 'Ad-free experience across the app',
    },
    {
      'icon': '💎',
      'title': 'Priority Support',
      'description': 'Get help faster from our support team',
    },
    {
      'icon': '🔄',
      'title': 'Cloud Sync',
      'description': 'Sync your data across all devices',
    },
  ];

  // ─── Load products ───────────────────────────────────────────────────────

  Future<void> _loadProducts() async {
    isLoading.value = true;
    loadFailed.value = false;
    try {
      await _iapService.loadProducts();

      if (_iapService.products.isEmpty) {
        print('⚠️ [PremiumController] No products loaded from store');
        loadFailed.value = true;
      } else {
        productsLoaded.value = true;
        pricing.logPricingDetails();
      }
    } catch (e) {
      print('❌ [PremiumController] Error loading products: $e');
      loadFailed.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Retry loading products (called from UI on failure).
  Future<void> retryLoadProducts() => _loadProducts();

  // ─── Plan selection ──────────────────────────────────────────────────────

  void selectPlan(int index) {
    selectedPlan.value = index;
  }

  // ─── Purchase ────────────────────────────────────────────────────────────

  Future<void> upgradeToPremium() async {
    if (isLoading.value) return;

    final productId = selectedProductId;
    print('🛒 [PremiumController] Starting purchase for: $productId');
    print('💰 [PremiumController] Price: ${pricing.getPriceText(productId)} | rawPrice: ${pricing.getRawPrice(productId)} | currency: ${pricing.getCurrencyCodeForProduct(productId)}');

    isLoading.value = true;
    try {
      await _iapService.purchaseProduct(productId);
      // Purchase flow started — loading will be reset by IAPService
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process purchase: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Restore ─────────────────────────────────────────────────────────────

  void restorePurchases() {
    _iapService.restorePurchases();
  }
}
