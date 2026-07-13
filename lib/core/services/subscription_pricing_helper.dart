import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'iap_service.dart';

/// Central pricing helper — single source of truth for subscription pricing.
///
/// ALL prices come exclusively from the store (Google Play / App Store).
/// Never hardcode prices. Never detect country via IP, locale, or timezone.
/// The subscription product itself carries the localized price for the user's
/// store account region.
class SubscriptionPricingHelper {
  final IAPService _iapService;

  SubscriptionPricingHelper(this._iapService);

  // ─── Product accessors ────────────────────────────────────────────────────

  ProductDetails? get _monthlyProduct =>
      _iapService.productMap[IAPService.monthlySubscriptionId];

  ProductDetails? get _yearlyProduct =>
      _iapService.productMap[IAPService.yearlySubscriptionId];

  // ─── Loaded check ─────────────────────────────────────────────────────────

  bool get areProductsLoaded =>
      _monthlyProduct != null || _yearlyProduct != null;

  // ─── Formatted price text (e.g. "₹297", "$9.99") ─────────────────────────

  /// Returns the store-formatted monthly price string.
  /// Falls back to empty string if product is not yet loaded.
  String getMonthlyPriceText() {
    final p = _monthlyProduct;
    if (p == null) return '';
    print('💰 [Pricing] Monthly price: ${p.price} (${p.currencyCode})');
    return p.price;
  }

  /// Returns the store-formatted yearly price string.
  /// Falls back to empty string if product is not yet loaded.
  String getYearlyPriceText() {
    final p = _yearlyProduct;
    if (p == null) return '';
    print('💰 [Pricing] Yearly price: ${p.price} (${p.currencyCode})');
    return p.price;
  }

  /// Returns the formatted price for a given product ID.
  String getPriceText(String productId) {
    final p = _iapService.productMap[productId];
    return p?.price ?? '';
  }

  // ─── Raw prices for revenue / commission calculations ─────────────────────

  /// Raw numeric monthly price (no currency symbol, no formatting).
  /// Use for commission math, revenue tracking, etc.
  double getMonthlyRawPrice() {
    final p = _monthlyProduct;
    if (p == null) {
      print('⚠️ [Pricing] Monthly product not loaded; using 0.0 for rawPrice');
      return 0.0;
    }
    print('💰 [Pricing] Monthly rawPrice: ${p.rawPrice}');
    return p.rawPrice;
  }

  /// Raw numeric yearly price.
  double getYearlyRawPrice() {
    final p = _yearlyProduct;
    if (p == null) {
      print('⚠️ [Pricing] Yearly product not loaded; using 0.0 for rawPrice');
      return 0.0;
    }
    print('💰 [Pricing] Yearly rawPrice: ${p.rawPrice}');
    return p.rawPrice;
  }

  /// Raw price for any product ID.
  double getRawPrice(String productId) {
    return _iapService.productMap[productId]?.rawPrice ?? 0.0;
  }

  // ─── Currency code (ISO 4217 e.g. "INR", "USD", "EUR") ───────────────────

  /// ISO 4217 currency code from the monthly product.
  /// The store account region determines this — never detect manually.
  String getCurrencyCode() {
    return _monthlyProduct?.currencyCode ??
        _yearlyProduct?.currencyCode ??
        '';
  }

  /// Currency code for a specific product.
  String getCurrencyCodeForProduct(String productId) {
    return _iapService.productMap[productId]?.currencyCode ?? '';
  }

  // ─── Debug log ────────────────────────────────────────────────────────────

  void logPricingDetails() {
    print('─── [SubscriptionPricingHelper] Pricing Details ───');
    print('📦 Platform: ${Platform.isIOS ? "iOS" : "Android"}');
    print('📦 Monthly product ID: ${IAPService.monthlySubscriptionId}');
    print('📦 Yearly product ID:  ${IAPService.yearlySubscriptionId}');

    final monthly = _monthlyProduct;
    if (monthly != null) {
      print('✅ Monthly → price: ${monthly.price} | rawPrice: ${monthly.rawPrice} | currency: ${monthly.currencyCode} | title: ${monthly.title}');
    } else {
      print('❌ Monthly product not loaded');
    }

    final yearly = _yearlyProduct;
    if (yearly != null) {
      print('✅ Yearly  → price: ${yearly.price} | rawPrice: ${yearly.rawPrice} | currency: ${yearly.currencyCode} | title: ${yearly.title}');
    } else {
      print('❌ Yearly product not loaded');
    }
    print('───────────────────────────────────────────────────');
  }
}
