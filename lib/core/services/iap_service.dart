import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class IAPService extends GetxService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Product IDs - MUST match store listings
  static const String monthlySubscriptionId = 'caloriz_premium_monthly';
  static String get yearlySubscriptionId =>
      Platform.isIOS ? 'caloriz_premium_yearly_v2' : 'caloriz_premium_yearly';

  // Observable states
  final RxBool isAvailable = false.obs;
  final RxBool isLoading = false.obs;
  final RxList<ProductDetails> products = <ProductDetails>[].obs;
  final RxMap<String, ProductDetails> productMap =
      <String, ProductDetails>{}.obs;

  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Track processed purchases in this session to prevent double-delivery
  final Set<String> _processedPurchaseIds = {};

  @override
  Future<IAPService> onInit() async {
    super.onInit();
    await _initialize();
    return this;
  }

  Future<void> _initialize() async {
    // Check if in-app purchase is available
    isAvailable.value = await _iap.isAvailable();

    if (!isAvailable.value) {
      print('In-App Purchase not available');
      return;
    }

    // Android billing client setup (pending purchases enabled by default)

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription.cancel(),
      onError: (error) => print('Purchase stream error: $error'),
    );

    // Load products
    await loadProducts();
  }

  Future<void> loadProducts() async {
    if (!isAvailable.value) {
      print('⚠️ [IAP] Store not available, skipping product load');
      return;
    }

    isLoading.value = true;

    try {
      final Set<String> productIds = {
        monthlySubscriptionId,
        yearlySubscriptionId,
      };

      print('🔍 [IAP] Querying products: $productIds');
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        productIds,
      );

      if (response.error != null) {
        print('❌ [IAP] Error loading products: ${response.error}');
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        print('⚠️ [IAP] Products not found: ${response.notFoundIDs}');
      }

      // On Android, subscription products with multiple offers return
      // multiple GooglePlayProductDetails for the same product ID.
      // We prefer the base plan offer (offerId == null) over promotional offers.
      productMap.clear();
      final List<ProductDetails> dedupedProducts = [];

      for (var product in response.productDetails) {
        final existingProduct = productMap[product.id];

        if (Platform.isAndroid && product is GooglePlayProductDetails) {
          final offerDetails = product.productDetails.subscriptionOfferDetails;
          final subIndex = product.subscriptionIndex;
          String? offerId;
          if (offerDetails != null && subIndex != null && subIndex < offerDetails.length) {
            offerId = offerDetails[subIndex].offerId;
          }
          print('🔍 [IAP] Product: ${product.id} | subscriptionIndex: $subIndex | offerId: $offerId | offerToken: ${product.offerToken} | price: ${product.price}');

          if (existingProduct != null && existingProduct is GooglePlayProductDetails) {
            // Already have this product - prefer the base plan (offerId == null)
            final existingOfferDetails = existingProduct.productDetails.subscriptionOfferDetails;
            final existingSubIndex = existingProduct.subscriptionIndex;
            String? existingOfferId;
            if (existingOfferDetails != null && existingSubIndex != null && existingSubIndex < existingOfferDetails.length) {
              existingOfferId = existingOfferDetails[existingSubIndex].offerId;
            }

            if (existingOfferId == null) {
              // Existing is base plan, keep it
              print('⏭️ [IAP] Skipping duplicate ${product.id} (keeping base plan)');
              continue;
            } else if (offerId == null) {
              // New one is base plan, replace
              print('🔄 [IAP] Replacing ${product.id} with base plan offer');
              dedupedProducts.removeWhere((p) => p.id == product.id);
            } else {
              // Both are promotional, keep existing
              print('⏭️ [IAP] Skipping duplicate ${product.id}');
              continue;
            }
          }
        } else {
          print('✅ [IAP] Product loaded: ${product.id} - ${product.price}');
          if (existingProduct != null) continue;
        }

        productMap[product.id] = product;
        dedupedProducts.add(product);
      }

      products.value = dedupedProducts;
      print('✅ [IAP] Loaded ${products.length} products (${response.productDetails.length} total from store)');
      _logLoadedProducts();
    } catch (e) {
      print('❌ [IAP] Error loading products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> purchaseProduct(String productId) async {
    if (!isAvailable.value) {
      Get.snackbar(
        'Not Available',
        'In-app purchases are not available on this device',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final product = productMap[productId];
    if (product == null) {
      Get.snackbar(
        'Error',
        'Product not found',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      late final PurchaseParam purchaseParam;

      if (Platform.isAndroid && product is GooglePlayProductDetails) {
        final googleProduct = product;
        print('🔍 [IAP] Purchasing Android product: ${googleProduct.id}');
        print('🔍 [IAP]   productType: ${googleProduct.productDetails.productType}');
        print('🔍 [IAP]   subscriptionIndex: ${googleProduct.subscriptionIndex}');
        print('🔍 [IAP]   offerToken: ${googleProduct.offerToken}');

        purchaseParam = GooglePlayPurchaseParam(
          productDetails: googleProduct,
        );
      } else {
        purchaseParam = PurchaseParam(
          productDetails: product,
        );
      }

      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      // Purchase flow started - loading will be reset by _handlePurchaseUpdates
    } catch (e) {
      print('Purchase error: $e');
      Get.snackbar(
        'Purchase Failed',
        'Failed to start purchase: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      print('Purchase update: ${purchase.status} | id: ${purchase.purchaseID}');

      if (purchase.status == PurchaseStatus.pending) {
        // Show pending state
        Get.snackbar(
          'Processing',
          'Purchase is being processed...',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (purchase.status == PurchaseStatus.error) {
        // Handle error
        Get.snackbar(
          'Purchase Failed',
          purchase.error?.message ?? 'Unknown error',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
      } else if (purchase.status == PurchaseStatus.purchased) {
        // NEW PURCHASE — verify and deliver
        final purchaseKey = purchase.purchaseID ?? purchase.productID;

        if (_processedPurchaseIds.contains(purchaseKey)) {
          print('⚠️ [IAP] Skipping duplicate purchase event: $purchaseKey');
        } else {
          _processedPurchaseIds.add(purchaseKey);
          final valid = await _verifyPurchase(purchase);
          if (valid) {
            await _deliverProduct(purchase);
            Get.snackbar(
              'Success! 🎉',
              'You are now a Premium member!',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 3),
            );
          }
        }

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        isLoading.value = false;
      } else if (purchase.status == PurchaseStatus.restored) {
        // RESTORED PURCHASE — only update premium status, do NOT re-credit referral
        print('🔄 [IAP] Restoring purchase: ${purchase.productID}');
        try {
          final userId = _authService.currentUserId.value;
          if (userId != null) {
            await _firestore.collection('users').doc(userId).update({
              'isPremium': true,
            });
            _authService.isPremium.value = true;
          }
        } catch (e) {
          print('Error restoring premium status: $e');
        }

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        isLoading.value = false;
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // Basic client-side verification
    // On iOS StoreKit 2, serverVerificationData may be empty
    // The purchase status itself (PurchaseStatus.purchased) is sufficient for client-side
    if (Platform.isAndroid) {
      return purchase.verificationData.serverVerificationData.isNotEmpty;
    } else if (Platform.isIOS) {
      // On iOS, if we got PurchaseStatus.purchased, the StoreKit verified it
      return true;
    }
    return false;
  }

  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    try {
      final userId = _authService.currentUserId.value;
      if (userId == null) return;

      // Update user's premium status in Firebase
      await _firestore.collection('users').doc(userId).update({
        'isPremium': true,
        'premiumPurchasedAt': FieldValue.serverTimestamp(),
        'premiumProductId': purchase.productID,
        'premiumPurchaseId': purchase.purchaseID,
      });

      // Update local premium status
      _authService.isPremium.value = true;

      // Check if this user was a referral and update referral status
      try {
        final referralQuery = await _firestore
            .collection('referrals')
            .where('referredUserId', isEqualTo: userId)
            .limit(1)
            .get();

        if (referralQuery.docs.isNotEmpty) {
          final referralDoc = referralQuery.docs.first;
          final referralData = referralDoc.data();

          if (referralData['status'] != 'completed') {
            final referrerId = referralData['referrerId'];

            // Commission rates: India 30%, International 50%.
            // Region is determined by the store account — we read it from
            // the product's currencyCode, NEVER from IP/locale/timezone.
            const double indiaCommissionRate = 0.30;
            const double intlCommissionRate = 0.50;

            // Use live store product for price — single source of truth.
            final product = productMap[purchase.productID];
            final rawPrice = product?.rawPrice ?? 0.0;
            final currencyCode = product?.currencyCode ?? '';
            final priceDisplay = product?.price ?? purchase.productID;

            // Determine commission rate from currency code (INR = India)
            final commissionRate = currencyCode == 'INR'
                ? indiaCommissionRate
                : intlCommissionRate;

            // Commission is a percentage of the actual store raw price
            final commissionAmount = rawPrice * commissionRate;

            print(
              '💰 [IAP] Commission: ${commissionAmount.toStringAsFixed(2)} $currencyCode '
              '(${(commissionRate * 100).toStringAsFixed(0)}% of $priceDisplay | rawPrice=$rawPrice)',
            );

            // Update Referral Doc
            await referralDoc.reference.update({
              'status': 'completed',
              'completedAt': FieldValue.serverTimestamp(),
              'premiumProductId': purchase.productID,
              'commissionAmount': commissionAmount,
            });

            // Credit Referrer
            if (referrerId != null) {
              await _firestore.collection('users').doc(referrerId).update({
                'walletBalance': FieldValue.increment(commissionAmount),
                'totalEarned': FieldValue.increment(commissionAmount),
                'referralCount': FieldValue.increment(1),
              });
              print('💰 Credited $commissionAmount $currencyCode to referrer: $referrerId');
            }

            print('✅ Referral status updated to COMPLETED for user: $userId');
          }
        }
      } catch (e) {
        print('Error updating referral status: $e');
      }

      // TRACK REVENUE (Global Stat)
      // Revenue is stored in local currency units from the store product.
      // rawPrice is what the store reports — no conversion, no hardcoding.
      try {
        final product = productMap[purchase.productID];
        final rawPrice = product?.rawPrice ?? 0.0;
        final currencyCode = product?.currencyCode ?? 'UNKNOWN';
        final priceDisplay = product?.price ?? purchase.productID;

        if (rawPrice > 0) {
          await _firestore.collection('settings').doc('global_stats').set({
            'totalRevenue': FieldValue.increment(rawPrice),
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          print('📈 Revenue tracked: +$rawPrice $currencyCode (product: $priceDisplay)');
        } else {
          print('⚠️ [IAP] rawPrice is 0 for ${purchase.productID} — product may not be loaded yet');
        }
      } catch (e) {
        print('Error tracking revenue: $e');
      }

      print('Premium delivered to user: $userId');
    } catch (e) {
      print('Error delivering product: $e');
    }
  }

  Future<void> restorePurchases() async {
    if (!isAvailable.value) {
      Get.snackbar(
        'Not Available',
        'In-app purchases are not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      await _iap.restorePurchases();

      Get.snackbar(
        'Restore Complete',
        'Your purchases have been restored',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Restore error: $e');
      Get.snackbar(
        'Restore Failed',
        'Failed to restore purchases: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Logs full pricing details for all loaded products.
  void _logLoadedProducts() {
    print('─── [IAP] Loaded Product Details ───');
    for (final product in products) {
      print(
        '  📦 id: ${product.id}'
        ' | price: ${product.price}'
        ' | rawPrice: ${product.rawPrice}'
        ' | currencyCode: ${product.currencyCode}'
        ' | title: ${product.title}',
      );
    }
    print('────────────────────────────────────');
  }

  /// Returns the store-formatted price string for [product].
  /// This is the ONLY value that should appear in the UI for pricing.
  String formatPrice(ProductDetails product) {
    return product.price;
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
