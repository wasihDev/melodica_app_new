import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:melodica_app_new/models/user_model.dart';
import 'package:melodica_app_new/utils/snacbar_utils.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:image_picker/image_picker.dart';

class UserprofileProvider extends ChangeNotifier {
  UserprofileProvider() {
    fetchUserData();
    loadImageFromPrefs();
  }
  final FirebaseAuth auth = FirebaseAuth.instance;
  // late BuildContext _context;
  // BuildContext get context => _context;

  // void setContext(BuildContext context) {
  //   _context = context;
  // }

  UserModel _userModel = UserModel();
  bool _isLoading = false;
  File? _pickedImage;
  Uint8List? _uint8list;
  // getters
  bool get isLoading => _isLoading;
  UserModel get userModel => _userModel;
  File? get pickedImage => _pickedImage;
  Uint8List? get uint8list => _uint8list;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveProfile({required Map<String, dynamic> data}) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('No signed-in user');

    final docRef = _firestore.collection('users').doc(user.uid);
    // set with merge true to create or update partial fields
    await docRef.set(data, SetOptions(merge: true));
    // no need to call notifyListeners because snapshot listener will update model
  }

  // Fetch User Data
  Future<UserModel?> fetchUserData() async {
    try {
      print('data call');
      setLoading(true);
      final uid = auth.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        _userModel = UserModel.fromJson(
          snapshot.data() as Map<String, dynamic>,
        );
        print('data $_userModel');
      }
      setLoading(false);
      notifyListeners();

      return _userModel;
    } catch (e) {
      print('error $e');
      // SnackbarUtils.showError(context, 'Error $e');
    } finally {
      setLoading(false);
    }
    notifyListeners();
    return _userModel;
  }

  // Update User Data
  Future<UserModel?> updateUserData(
    BuildContext context, {
    required Map<String, dynamic> data,
  }) async {
    setLoading(true);
    final uid = auth.currentUser?.uid;

    if (uid != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update(data);
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        _userModel = UserModel.fromJson(
          snapshot.data() as Map<String, dynamic>,
        );
        SnackbarUtils.showSuccess(context, 'Name updated');
        print('Updated user: $_userModel');
      } catch (e) {
        print('Error updating user: $e');
      }
    }

    setLoading(false);
    notifyListeners();
    return _userModel;
  }

  // Pick image
  Future<void> pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _pickedImage = File(picked.path);
      await SaveImagePrefs(_pickedImage!);
      SnackbarUtils.showSuccess(context, "Image Updated");
      notifyListeners();
    }
  }

  // Save Image
  Future<void> SaveImagePrefs(File value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bytes = await value.readAsBytes();
    final encodedImage = base64Encode(bytes);
    await prefs.setString('user_image', encodedImage);
    _uint8list = bytes;
    MemoryImage(bytes);
    print('image is ssaved');
  }

  // Load Image
  Future<void> loadImageFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedImage = await prefs.getString('user_image');
      if (encodedImage != null) {
        final bytes = base64Decode(encodedImage);
        _pickedImage = File.fromRawPath(bytes);
        _uint8list = bytes;
        MemoryImage(_uint8list!);
        notifyListeners();
      }
    } catch (e) {
      print('error $e');
    }
  }

  // loading
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  //clear prefs
  Future<void> clearImage() async {
    _pickedImage = null;
    _uint8list = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_image');
    notifyListeners();
  }

  void clearUser() {
    print('before ${userModel.image}');
    _userModel = UserModel(uid: '', firstName: '', email: '', image: '');
    print('after ${userModel.image}');
    notifyListeners();
  }
}

// after break i will check user logout
