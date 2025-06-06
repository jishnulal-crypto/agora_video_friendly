import 'package:agora_video_friendly/models/appuser.dart';
import 'package:agora_video_friendly/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

class CallNotificationProvider extends ChangeNotifier {
  static const platform = MethodChannel(
    'com.example.agora_video_friendly/call_overlay',
  );

  CallNotificationProvider() {
    _initFCM();
    _listenToIncomingCalls(); 
  }

  void _initFCM() async {
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  void _listenToIncomingCalls() async {
    AppUser? appUser = await UserProvider.getUserFromPrefs();
    final userId = appUser?.uid;
    if (userId == null) {
      print("User ID not found in prefs.");
      return;
    }

    FirebaseFirestore.instance
        .collection('calls')
        .where('receiverId', isEqualTo: userId)
        .where('hasDialled', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.docs) {
            final callData = doc.data();

            if (_isCallMessage(callData)) {
              _showIncomingCall(callData);
            }
          }
        });
  }

  void _handleMessage(RemoteMessage message) {
    if (_isCallMessage(message.data)) {
      _showIncomingCall(message.data);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Handle when user taps notification
  }

  bool _isCallMessage(Map<String, dynamic> data) {
    return data['type'] == 'audio_call' || data['type'] == 'video_call';
  }

  Future<void> _showIncomingCall(Map<String, dynamic> data) async {
    try {
      await platform.invokeMethod('showIncomingCall', data);
    } catch (e) {
      debugPrint('Error invoking native method: $e');
    }
  }
}
