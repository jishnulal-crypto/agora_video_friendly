import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class CallInitiationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  final String _notificationServerUrl = 'http://localhost:3000/send-notification';

  Future<void> startCall({
    required String callerId,
    required String receiverId,
    required String receiverName,
    required String receiverPhoto,
    required bool isVideo,
  }) async {
    final callId = "$callerId-$receiverId";

    // Save call data to Firestore
    await _firestore.collection('calls').doc(callId).set({
      'callerId': callerId,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPhoto': receiverPhoto,
      'isVideo': isVideo,
      'status': 'ringing',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Get receiver's FCM token from Firestore
    final receiverDoc = await _firestore.collection('users').doc(receiverId).get();
    final receiverFcmToken = receiverDoc.data()?['fcmToken'];

    if (receiverFcmToken == null) {
      print('Receiver FCM token not found');
      return;
    }

    // Send notification
    await _sendFcmNotification(
      fcmToken: receiverFcmToken,
      title: 'Incoming ${isVideo ? 'Video' : 'Audio'} Call',
      body: 'Call from $callerId',
      data: {
        'type': 'call',
        'callerId': callerId,
        'receiverId': receiverId,
        'isVideo': isVideo.toString(),
        'channelId': callId,
      },
    );
  }

  Future<void> _sendFcmNotification({
    required String fcmToken,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    final payload = json.encode({
      'token': fcmToken,
      'title': title,
      'body': body,
      'data': data,
    });
    
    try {
      final response = await http.post(
        Uri.parse(_notificationServerUrl),
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> endCall(String callerId, String receiverId) async {
    final callId = "$callerId-$receiverId";
    await _firestore.collection('calls').doc(callId).delete();
  }
}
