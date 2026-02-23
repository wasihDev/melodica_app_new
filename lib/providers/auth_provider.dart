// auth_provider.dart
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:melodica_app_new/helper/shared_pref_helper.dart';
import 'package:melodica_app_new/models/user_model.dart';
import 'package:melodica_app_new/providers/user_profile_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/services/auth_services.dart';
import 'package:melodica_app_new/utils/authExceptionHandler.dart';
import 'package:melodica_app_new/utils/snacbar_utils.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

class AuthProviders extends ChangeNotifier {
  String? _emailForReset;
  String? get emailForReset => _emailForReset;
  final _googleSignin = GoogleSignIn();
  final FirebaseAuth auth = FirebaseAuth.instance;
  late BuildContext _context;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _userModel;
  bool _isGuest = false;

  bool get isGuest => _isGuest;

  bool _isLoading = false;
  bool _isLoadingGoogle = false;
  bool _isLoadingFacebook = false;
  bool _isLoadingApple = false;
  bool _isDeleting = false;
  AuthService _authService = AuthService();
  BuildContext get context => _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  // getters
  UserModel get userModel => _userModel!;
  bool get isLoading => _isLoading;
  bool get isLoadingFacebook => _isLoadingFacebook;
  bool get isDeleting => _isDeleting;
  bool get isLoadingGoogle => _isLoadingGoogle;
  bool get isLoadingApple => _isLoadingApple;
  // Simulated "code" for verification (in real app send via backend)

  // simulate sign up: return null on success or error message
  Future<void> loginFunc(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    setLoading(true);
    try {
      _userModel = await _authService.login(
        context: context,
        email: email,
        password: password,
      );

      if (_userModel != null) {
        // fetch profile and resources only if login succeeded

        _userModel = await Provider.of<UserprofileProvider>(
          context,
          listen: false,
        ).fetchUserData();
        print('_userModel ==>>> $_userModel   ');
        // final bool isPremium = userprovider.resources?.user?.ispremium ?? false;

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (Route<dynamic> route) => false,
        );
        notifyListeners();
      } else {
        // SnackbarUtils.showError(context, languages.invalidEmail);
      }
    } on FirebaseAuthException catch (e) {
      final errorMsg = AuthExceptionHandler.handleAuthException(e);
      SnackbarUtils.showError(navigatorKey.currentContext!, errorMsg);
    } finally {
      setLoading(false);
    }
  }

  // Registration
  Future<void> registrationFunc(
    BuildContext context, {
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      setLoading(true);
      _userModel = await _authService.signup(
        email: email,
        password: password,
        context: context,
        name: name,
      );

      if (_userModel != null) {
        _userModel = await Provider.of<UserprofileProvider>(
          context,
          listen: false,
        ).fetchUserData();

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (Route<dynamic> route) => false,
        );
      }
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      final errorMsg = AuthExceptionHandler.handleAuthException(e);
      SnackbarUtils.showError(context, "Apple login error: $errorMsg");
    } catch (e) {
      SnackbarUtils.showError(context, 'Error $e');
    } finally {
      setLoading(false);
    }
  }

  ///google provider
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      _isLoadingGoogle = true;
      notifyListeners();
      final GoogleSignInAccount? googleUser = await _googleSignin.signIn();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userAuth = await auth.signInWithCredential(credential);
      final uid = userAuth.user?.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        final email = googleUser.email;
        _userModel = UserModel(
          uid: uid,
          email: email,
          firstName: userAuth.user!.displayName,
          tokenId: await userAuth.user!.getIdToken(),
          image:
              'https://cdn4.iconfinder.com/data/icons/mixed-set-1-1/128/28-512.png',
        );

        await _firestore.collection('users').doc(uid).set(_userModel!.toJson());
      } else {
        _userModel = UserModel.fromJson(userDoc.data()!);
      }
      LocalStorageService.saveAuthToken("${await userAuth.user!.getIdToken()}");

      if (_userModel != null) {
        _userModel = await Provider.of<UserprofileProvider>(
          context,
          listen: false,
        ).fetchUserData();

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (Route<dynamic> route) => false,
        );
        _isLoadingGoogle = false;
        notifyListeners();
        SnackbarUtils.showSuccess(context, "logout Successfully");
      }
    } on FirebaseAuthException catch (e) {
      final errorMsg = AuthExceptionHandler.handleAuthException(e);
      SnackbarUtils.showError(context, "Google login error: $errorMsg");
    } catch (e) {
      print('error 123213$e');
      SnackbarUtils.showError(context, 'error $e');
    } finally {
      _isLoadingGoogle = false;
      notifyListeners();
    }
  }

  /// Facebook login
  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      _isLoadingFacebook = true;
      notifyListeners();

      // 1. Login with Facebook
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        SnackbarUtils.showError(context, "Facebook login cancelled");
        return;
      }

      final AccessToken accessToken = result.accessToken!;

      // 2. Create Firebase credential
      final OAuthCredential credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      // 3. Firebase Sign In
      final UserCredential userCredential = await auth.signInWithCredential(
        credential,
      );

      final user = userCredential.user!;
      final uid = user.uid;

      // 4. Check Firestore user
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        _userModel = UserModel(
          uid: user.uid,
          email: user.email ?? "",
          firstName: user.displayName ?? "Facebook User",
          tokenId: await user.getIdToken(),
          image:
              user.photoURL ??
              'https://cdn4.iconfinder.com/data/icons/mixed-set-1-1/128/28-512.png',
        );

        // Save new user
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(_userModel!.toJson(), SetOptions(merge: true));
      } else {
        _userModel = UserModel.fromJson(userDoc.data()!);
      }

      // 5. Save Token
      if (_userModel != null) {
        await LocalStorageService.saveAuthToken(_userModel!.tokenId!);

        _userModel = await Provider.of<UserprofileProvider>(
          context,
          listen: false,
        ).fetchUserData();

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (route) => false,
        );

        SnackbarUtils.showSuccess(context, "Successfully login via Facebook");
      }
    } on FirebaseAuthException catch (e) {
      final errorMsg = AuthExceptionHandler.handleAuthException(e);
      SnackbarUtils.showError(context, errorMsg);
    } catch (e) {
      print('Facebook error: $e');
    } finally {
      _isLoadingFacebook = false;
      notifyListeners();
    }
  }

  /// apple logim

  Future<void> signInWithApple(BuildContext context) async {
    try {
      _isLoadingApple = true;
      notifyListeners();

      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // 1. Get Apple Credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // 2. Create Firebase OAuth credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );

      // 3. Sign in with Firebase
      final userCredential = await auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;
      final uid = user!.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        _userModel = UserModel(
          uid: user.uid,
          email: user.email ?? "",
          firstName:
              appleCredential.givenName ??
              user.displayName ??
              "Apple User", // fallback
          tokenId: await user.getIdToken(),
          image:
              'https://cdn4.iconfinder.com/data/icons/mixed-set-1-1/128/28-512.png',
        );

        // 5. Save user in Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(_userModel!.toJson(), SetOptions(merge: true));
      } else {
        _userModel = UserModel.fromJson(userDoc.data()!);
      }
      if (_userModel != null) {
        // 6. Save Token in SharedPrefs
        await LocalStorageService.saveAuthToken(_userModel!.tokenId!);

        if (_userModel != null) {
          _userModel = await Provider.of<UserprofileProvider>(
            context,
            listen: false,
          ).fetchUserData();

          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.dashboard,
            (Route<dynamic> route) => false,
          );
          SnackbarUtils.showSuccess(context, "Successfully login via Apple");
        }
      }
    } on FirebaseAuthException catch (e) {
      final errorMsg = AuthExceptionHandler.handleAuthException(e);
      SnackbarUtils.showError(context, errorMsg);
    } catch (e) {
      print('catch $e');
      if (e is FirebaseAuthException) {
        final errorMsg = AuthExceptionHandler.handleAuthException(e);
        SnackbarUtils.showError(context, errorMsg);
      } else if (e is SignInWithAppleAuthorizationException) {
        SnackbarUtils.showError(context, "Apple Sign-In was cancelled");
      } else {
        SnackbarUtils.showError(context, "Something went wrong: $e");
      }
    } finally {
      _isLoadingApple = false;
      notifyListeners();
    }
  }

  String _generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Hash string to SHA256
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(
    BuildContext context,
    String email,
  ) async {
    try {
      setLoading(true);
      await auth.sendPasswordResetEmail(email: email);
      SnackbarUtils.showSuccess(
        context,
        'Send email for reset password on this $email',
      );

      setLoading(false);

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      SnackbarUtils.showError(context, 'Error $e');
      setLoading(false);
    } catch (e) {
      SnackbarUtils.showError(context, 'Error $e');
      setLoading(false);
    } finally {
      setLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      Provider.of<UserprofileProvider>(context, listen: false).clearUser();
      await LocalStorageService.clearAuthToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("active_subscription_id");
      await prefs.remove("subscription_token");
      await prefs.remove("subscription_start_date");

      await auth.signOut();
      await _googleSignin.signOut(); // Sign out from Google

      SnackbarUtils.showSuccess(context, 'logout Successfully');
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (Route<dynamic> route) => false,
      );
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      final errorMsg = AuthExceptionHandler.handleAuthException(e);
      SnackbarUtils.showError(context, "Apple login error: $errorMsg");
    } catch (e) {
      print('eror $e');
      SnackbarUtils.showError(context, 'Error $e');
    }
  }
}
