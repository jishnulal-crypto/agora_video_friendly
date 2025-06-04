import 'package:flutter/material.dart';
import '../services/call_initiation_service.dart';

class CallProvider extends ChangeNotifier {
  final CallInitiationService _callService = CallInitiationService();

  bool _isCalling = false;
  bool get isCalling => _isCalling;

  Future<void> startCall({
    required String callerId,
    required String receiverId,
    required String receiverName,
    required String receiverPhoto,
    required bool isVideo,
  }) async {
    _isCalling = true;
    notifyListeners();

    await _callService.startCall(
      callerId: callerId,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverPhoto: receiverPhoto,
      isVideo: isVideo,
    );
  }

  Future<void> endCall(String callerId, String receiverId) async {
    await _callService.endCall(callerId, receiverId);
    _isCalling = false;
    notifyListeners();
  }
}
