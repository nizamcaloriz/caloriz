import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:async';
import '../../firebase_options.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<String?> currentUserId = Rx<String?>(null);
  final Rx<String?> currentUserEmail = Rx<String?>(null);
  final Rx<String?> currentUserName = Rx<String?>(null);
  final RxBool isPremium = false.obs;
  final RxBool isNewUser = false.obs;
  Timer? _premiumCheckTimer;

  bool get isLoggedIn => currentUserId.value != null;

  Future<AuthService> init() async {
    // CRITICAL: Initialize GoogleSignIn (required in v7.x)
    // serverClientId is needed on iOS to get idToken for Firebase auth
    await _googleSignIn.initialize(
      serverClientId: DefaultFirebaseOptions.currentPlatform.androidClientId,
    );

    // Check current user on init
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Check if user is banned
      final isBanned = await checkBanStatus(currentUser.uid);
      if (isBanned) {
        await signOut();
        return this;
      }

      currentUserId.value = currentUser.uid;
      currentUserEmail.value = currentUser.email;
      currentUserName.value = currentUser.displayName;

      // Load premium status from Firebase
      await _loadPremiumStatus(currentUser.uid);

      // Start periodic premium status check (every 1 hour)
      _startPremiumCheckTimer(currentUser.uid);
    }

    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        currentUserId.value = user.uid;
        currentUserEmail.value = user.email;
        currentUserName.value = user.displayName;
        // Load premium status when user changes
        _loadPremiumStatus(user.uid);
        // Start timer for this user
        _startPremiumCheckTimer(user.uid);
      } else {
        currentUserId.value = null;
        currentUserEmail.value = null;
        currentUserName.value = null;
        isPremium.value = false;
        _premiumCheckTimer?.cancel();
      }
    });

    return this;
  }

  void _startPremiumCheckTimer(String userId) {
    // Cancel existing timer if active
    if (_premiumCheckTimer != null && _premiumCheckTimer!.isActive) {
      _premiumCheckTimer!.cancel();
    }

    print('⏰ Starting premium status check timer (every 1 hour)');

    // Check every 1 hour
    _premiumCheckTimer = Timer.periodic(const Duration(hours: 1), (
      timer,
    ) async {
      print('🔄 [PERIODIC CHECK] Checking subscription status...');
      await _loadPremiumStatus(userId);
    });
  }

  Future<bool> checkBanStatus(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && (doc.data()?['isBanned'] ?? false) == true) {
        print('🚫 User is BANNED');
        Get.defaultDialog(
          title: 'Account Banned',
          middleText:
              'Your account has been suspended due to policy violations.',
          textConfirm: 'OK',
          confirmTextColor: const Color(0xFFFFFFFF), // White text
          buttonColor: const Color(0xFFE53935), // Red color
          onConfirm: () {
            if (Get.isDialogOpen ?? false) Get.back();
          },
          barrierDismissible: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking ban status: $e');
      return false;
    }
  }

  Future<void> _loadPremiumStatus(String userId) async {
    try {
      print('📋 [PREMIUM CHECK] Loading subscription status...');
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        bool isPremiumUser = data['isPremium'] ?? false;

        print('🔍 Firebase isPremium: $isPremiumUser');

        // Check if subscription has expired
        if (isPremiumUser) {
          final premiumPurchasedAt = data['premiumPurchasedAt'] as Timestamp?;
          final premiumProductId = data['premiumProductId'] as String?;

          if (premiumPurchasedAt != null && premiumProductId != null) {
            print('📅 Purchased at: ${premiumPurchasedAt.toDate()}');
            print('🎁 Product ID: $premiumProductId');

            // Calculate subscription expiry date
            DateTime purchaseDate = premiumPurchasedAt.toDate();
            DateTime expiryDate;

            if (premiumProductId == 'caloriz_premium_monthly') {
              expiryDate = purchaseDate.add(const Duration(days: 30));
              print('📆 Subscription type: Monthly (30 days)');
            } else if (premiumProductId == 'caloriz_premium_yearly' || premiumProductId == 'caloriz_premium_yearly_v2') {
              expiryDate = purchaseDate.add(const Duration(days: 365));
              print('📆 Subscription type: Yearly (365 days)');
            } else {
              expiryDate = purchaseDate.add(
                const Duration(days: 30),
              ); // Default to 30 days
              print('📆 Subscription type: Unknown (defaulting to 30 days)');
            }

            DateTime now = DateTime.now();
            Duration remainingTime = expiryDate.difference(now);

            print('⏰ Expiry date: $expiryDate');
            print('⏱️ Current time: $now');
            print('⏳ Remaining days: ${remainingTime.inDays}');

            // Check if subscription has expired
            if (now.isAfter(expiryDate)) {
              print('❌ Subscription EXPIRED!');
              isPremiumUser = false;

              // Update Firebase to mark as expired
              await _firestore.collection('users').doc(userId).set({
                'isPremium': false,
                'subscriptionExpiredAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

              print('✅ Updated Firebase: isPremium set to false');
            } else {
              print('✅ Subscription ACTIVE');
              print('⏳ Expires in ${remainingTime.inDays} days');
            }
          }
        }

        isPremium.value = isPremiumUser;
      } else {
        print('⚠️ User document not found');
        isPremium.value = false;
      }
    } catch (e) {
      print('❌ Error loading premium status: $e');
      isPremium.value = false;
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Full interactive authentication only (v7.x)
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );

      if (googleUser == null) {
        // User cancelled the sign-in
        return {'success': false, 'isNewUser': false};
      }

      // Get authentication tokens (v7.x - this is NOT async!)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create credential for Firebase (only idToken is available in v7.x)
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;
      if (user != null) {
        // Check ban status
        final isBanned = await checkBanStatus(user.uid);
        if (isBanned) {
          await signOut();
          return {'success': false, 'error': 'Account is banned'};
        }

        currentUserId.value = user.uid;
        currentUserEmail.value = user.email;
        currentUserName.value = user.displayName;

        // Check if user has profile data
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        final bool isNew =
            !userDoc.exists || userDoc.data()?['profileComplete'] != true;
        isNewUser.value = isNew;

        // If new user, create basic user document with referral code
        if (!userDoc.exists) {
          // Generate unique referral code
          String referralCode = await _generateUniqueReferralCode(
            user.displayName ?? 'User',
          );

          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': user.displayName,
            'createdAt': FieldValue.serverTimestamp(),
            'profileComplete': false,
            'referralCode': referralCode,
            'referralCreatedAt': FieldValue.serverTimestamp(),
          });
        }

        return {'success': true, 'isNewUser': isNew};
      }

      return {'success': false, 'isNewUser': false, 'error': 'User is null'};
    } on GoogleSignInException catch (e) {
      print('Google Sign In Exception: ${e.code} - ${e.description}');
      return {
        'success': false,
        'isNewUser': false,
        'error': e.description ?? 'Failed to sign in with Google',
      };
    } catch (e) {
      print('Google Sign In Error: $e');
      return {'success': false, 'isNewUser': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      // Check if Apple Sign In is available (iOS 13+ or macOS 10.15+)
      if (!Platform.isIOS && !Platform.isMacOS) {
        return {
          'success': false,
          'isNewUser': false,
          'error': 'Apple Sign In is only available on iOS and macOS',
        };
      }

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        oauthCredential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        currentUserId.value = user.uid;
        currentUserEmail.value = user.email ?? appleCredential.email;

        // Apple only provides name on first sign in
        String? displayName = user.displayName;
        if (displayName == null && appleCredential.givenName != null) {
          displayName =
              '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                  .trim();
          if (displayName.isNotEmpty) {
            await user.updateDisplayName(displayName);
          }
        }
        currentUserName.value = displayName;

        // Check if user has profile data (to determine if new or existing)
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        final bool isNew =
            !userDoc.exists || userDoc.data()?['profileComplete'] != true;
        isNewUser.value = isNew;

        // If new user, create basic user document with referral code
        if (!userDoc.exists) {
          // Generate unique referral code
          String referralCode = await _generateUniqueReferralCode(
            displayName ?? 'User',
          );

          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email ?? appleCredential.email,
            'name': displayName,
            'createdAt': FieldValue.serverTimestamp(),
            'profileComplete': false,
            'referralCode': referralCode,
            'referralCreatedAt': FieldValue.serverTimestamp(),
          });
        }

        return {'success': true, 'isNewUser': isNew};
      }

      return {'success': false, 'isNewUser': false};
    } catch (e) {
      print('Apple Sign In Error: $e');
      return {'success': false, 'isNewUser': false, 'error': e.toString()};
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;
      if (user != null) {
        // Check ban status
        final isBanned = await checkBanStatus(user.uid);
        if (isBanned) {
          await signOut();
          return false;
        }

        currentUserId.value = user.uid;
        currentUserEmail.value = user.email;
        currentUserName.value = user.displayName;
        return true;
      }

      return false;
    } catch (e) {
      print('Sign In Error: $e');
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);

        currentUserId.value = user.uid;
        currentUserEmail.value = email;
        currentUserName.value = name;

        // Generate unique referral code
        String referralCode = await _generateUniqueReferralCode(name);

        // Create user document with referral code
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
          'profileComplete': false,
          'referralCode': referralCode,
          'referralCreatedAt': FieldValue.serverTimestamp(),
        });

        return true;
      }

      return false;
    } catch (e) {
      print('Sign Up Error: $e');
      return false;
    }
  }

  // Generate unique referral code
  Future<String> _generateUniqueReferralCode(String name) async {
    final random = Random();
    String code;
    bool isUnique = false;

    // Get first 2 letters of name (or fallback)
    String prefix = 'CA';
    if (name.isNotEmpty) {
      // Remove spaces and special chars, keep only letters
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

      print('🆕 Generating Referral Code: $code');

      // Check if code already exists
      final existingCode = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: code)
          .get();

      isUnique = existingCode.docs.isEmpty;
    } while (!isUnique);

    return code;
  }

  Future<void> completeProfile(Map<String, dynamic> profileData) async {
    try {
      final userId = currentUserId.value;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          ...profileData,
          'profileComplete': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // If user entered a referral code, create referral record
        if (profileData.containsKey('referredBy') &&
            profileData['referredBy'] != null &&
            profileData['referredBy'].toString().isNotEmpty) {
          final referralCode = profileData['referredBy'].toString();

          // Find the referrer by their referral code
          final referrerSnapshot = await _firestore
              .collection('users')
              .where('referralCode', isEqualTo: referralCode)
              .limit(1)
              .get();

          if (referrerSnapshot.docs.isNotEmpty) {
            final referrerId = referrerSnapshot.docs.first.id;

            // Create referral record
            await _firestore.collection('referrals').add({
              'referrerId': referrerId,
              'referredUserId': userId,
              'referredAt': FieldValue.serverTimestamp(),
              'status': 'pending', // Will become 'active' when they subscribe
            });
          }
        }
      }
    } catch (e) {
      print('Complete Profile Error: $e');
    }
  }

  // Link email/password to existing account (e.g., after Google Sign-In)
  Future<bool> linkEmailPassword(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if email/password provider already linked
      final providers = user.providerData
          .map((info) => info.providerId)
          .toList();
      if (providers.contains('password')) {
        print('Email/Password already linked');
        return true;
      }

      // Create email/password credential
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Link credential to current user
      await user.linkWithCredential(credential);

      print('✅ Email/Password linked successfully');
      return true;
    } catch (e) {
      print('Link Email/Password Error: $e');
      return false;
    }
  }

  // Check if user has email/password provider linked
  Future<bool> hasEmailPasswordProvider() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final providers = user.providerData
          .map((info) => info.providerId)
          .toList();
      return providers.contains('password');
    } catch (e) {
      return false;
    }
  }

  /// Permanently deletes the user's account from Firebase Auth and Firestore.
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'No user is currently signed in'};
      }

      final userId = user.uid;

      // 1. Delete user sub-collections from Firestore
      final subCollections = ['foodLogs', 'waterLogs', 'weightHistory'];
      for (final subCol in subCollections) {
        try {
          final snapshots = await _firestore
              .collection('users')
              .doc(userId)
              .collection(subCol)
              .get();
          for (final doc in snapshots.docs) {
            await doc.reference.delete();
          }
        } catch (e) {
          print('⚠️ Error deleting sub-collection $subCol: $e');
        }
      }

      // 2. Delete the main user document from Firestore
      try {
        await _firestore.collection('users').doc(userId).delete();
        print('✅ Firestore user document deleted');
      } catch (e) {
        print('⚠️ Error deleting Firestore user doc: $e');
      }

      // 3. Delete referral records
      try {
        final referralDocs = await _firestore
            .collection('referrals')
            .where('referredUserId', isEqualTo: userId)
            .get();
        for (final doc in referralDocs.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        print('⚠️ Error deleting referral records: $e');
      }

      // 4. Delete the Firebase Auth user
      try {
        await user.delete();
        print('✅ Firebase Auth user deleted');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          print('🔄 Re-authentication required, attempting...');
          // Try re-authenticating with Google
          final reAuthSuccess = await _reAuthenticateAndDelete(user);
          if (!reAuthSuccess) {
            return {
              'success': false,
              'error':
                  'Please sign out and sign in again, then try deleting your account.',
            };
          }
        } else {
          rethrow;
        }
      }

      // 5. Disconnect Google and clear local state
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}

      _premiumCheckTimer?.cancel();
      currentUserId.value = null;
      currentUserEmail.value = null;
      currentUserName.value = null;
      isPremium.value = false;
      isNewUser.value = false;

      print('✅ Account deleted successfully');
      return {'success': true};
    } catch (e) {
      print('❌ Delete Account Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Re-authenticate with Google and retry user.delete()
  Future<bool> _reAuthenticateAndDelete(User user) async {
    try {
      final googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );
      if (googleUser == null) return false;

      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);
      await user.delete();
      print('✅ Re-auth + delete succeeded');
      return true;
    } catch (e) {
      print('❌ Re-auth failed: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _auth.signOut();
    currentUserId.value = null;
    currentUserEmail.value = null;
    currentUserName.value = null;
    isPremium.value = false;
    isNewUser.value = false;
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Reset Password Error: $e');
      return false;
    }
  }

  Future<void> upgradeToPremium() async {
    // TODO: Implement premium subscription
    isPremium.value = true;
  }

  Future<bool> validateReferralCode(String code) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: code)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Validate Referral Code Error: $e');
      return false;
    }
  }

  @override
  void onClose() {
    // Cancel the premium check timer
    if (_premiumCheckTimer != null && _premiumCheckTimer!.isActive) {
      _premiumCheckTimer!.cancel();
      print('⏰ Premium check timer cancelled');
    }
    super.onClose();
  }
}
