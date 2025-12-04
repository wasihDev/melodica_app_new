import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:melodica_app_new/helper/shared_pref_helper.dart';
import 'package:melodica_app_new/utils/snacbar_utils.dart';
import '../models/user_model.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel userModel = UserModel();
  // Current Firebase user
  // User? get currentUser => _auth.currentUser;

  Future<UserModel?> signup({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('response 1 ${userCredential}');
      print('response 2 ${userCredential.credential}');
      print('response 3 ${userCredential.user}');
      final uid = userCredential.user?.uid;
      if (uid == null) {
        SnackbarUtils.showError(context, 'Failed to get user ID');
        return null;
      }

      userModel = UserModel(
        uid: uid,
        email: email,
        isGuest: false,
        name: name,
        tokenId: await userCredential.user!.getIdToken(),
        userSubcriptionRecipt: '',
        image:
            'https://cdn4.iconfinder.com/data/icons/mixed-set-1-1/128/28-512.png',
      );
      // setAs
      await _firestore.collection('users').doc(uid).set(userModel.toJson());
      LocalStorageService.saveAuthToken(
        "${await userCredential.user!.getIdToken()}",
      );

      return userModel;
    } catch (e) {
      SnackbarUtils.showError(context, 'Error: $e');
      return null;
    }
  }

  // Login function
  Future<UserModel?> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        SnackbarUtils.showError(context, 'Failed to get user ID');
        return null;
      }

      final userDoc = await _firestore.collection('users').doc(uid).get();
      log('uid Token ${await userCredential.user!.getIdToken()}');
      if (!userDoc.exists) {
        SnackbarUtils.showError(context, 'User data not found');
        return null;
      }
      LocalStorageService.saveAuthToken(
        "${await userCredential.user!.getIdToken()}",
      );

      return UserModel.fromJson(userDoc.data()!);
    } catch (e) {
      SnackbarUtils.showError(context, 'Error: $e');
      return null;
    }
  }
}
