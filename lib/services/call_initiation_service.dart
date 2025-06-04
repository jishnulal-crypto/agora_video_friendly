import 'package:cloud_firestore/cloud_firestore.dart';

class CallInitiationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> startCall({
    required String callerId,
    required String receiverId,
    required String receiverName,
    required String receiverPhoto,
    required bool isVideo,
  }) async {
    final callId = "$callerId-$receiverId";

    await _firestore.collection('calls').doc(callId).set({
      'callerId': callerId,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPhoto': receiverPhoto,
      'isVideo': isVideo,
      'status': 'ringing',
      'timestamp': FieldValue.serverTimestamp(),
    });

  }

  Future<void> endCall(String callerId, String receiverId) async {
    final callId = "$callerId-$receiverId";
    await _firestore.collection('calls').doc(callId).delete();
  }
  
}
