import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<String?> getFcmToken() async {
    await _fcm.requestPermission(); // for iOS
    return await _fcm.getToken();
  }

  void listenForTokenRefresh(String uid) {
    _fcm.onTokenRefresh.listen((newToken) {
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': newToken,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
