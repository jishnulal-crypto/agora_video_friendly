import 'package:agora_video_friendly/models/appuser.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart' as p;

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  User? _user;
  User? get user => _user;

  UserProvider() {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((user) async {
      _user = user;
      if (user != null) {
        await _saveUserToFirestore(user);
        await _saveUserToPrefs(user);
      }
      notifyListeners();
    });
  }

  Future<void> signInWithEmailPassword(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserToFirestore(cred.user!);
      await _saveUserToPrefs(cred.user!);

      Navigator.pushReplacementNamed(context, '/userList');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    await _saveUserToFirestore(userCredential.user!);
    await _saveUserToPrefs(userCredential.user!);

    Navigator.pushReplacementNamed(context, '/userList');
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await p.SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> _saveUserToFirestore(User user) async {
    final token = await _messaging.getToken();
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'fcmToken': token,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await p.SharedPreferences.getInstance();
    await prefs.setString('uid', user.uid);
    await prefs.setString('email', user.email ?? '');
    await prefs.setString('displayName', user.displayName ?? '');
    await prefs.setString('photoURL', user.photoURL ?? '');
  }

  static Future<AppUser?> getUserFromPrefs() async {
    final prefs = await p.SharedPreferences.getInstance();

    final uid = prefs.getString('uid');
    if (uid == null) return null;

    final userJson = {
      'uid': uid,
      'email': prefs.getString('email'),
      'displayName': prefs.getString('displayName'),
      'photoURL': prefs.getString('photoURL'),
    };

    return AppUser.fromJson(userJson);
  }
}
