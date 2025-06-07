import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import '../services/call_initiation_service.dart';
import '../services/audio_call_service.dart'; // Agora logic



class CallProvider extends ChangeNotifier {
  final CallInitiationService _callService = CallInitiationService();
  final AudioCallService _audioService = AudioCallService();

  // Public getters
  CallInitiationService get callService => _callService;
  AudioCallService get audioService => _audioService;
  RtcEngine get engine => audioService.engine;
  
  int? remoteUid;
  
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

    // 1. Start call in Firestore
    await _callService.fireStorePushingAndFcmSending(
      callerId: callerId,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverPhoto: receiverPhoto,
      isVideo: isVideo,
    );

    // 2. Start Agora call
    await _audioService.initialize(
      type: isVideo,
      onUserJoined: (uid) {
        print("Remote user joined: $uid");
        remoteUid = uid;
      },
      onUserOffline: (uid) {
        remoteUid = uid;
        print("Remote user left: $uid");
      },
    );
    await _audioService.channelConnect();
  }

  Future<void> endCall(String callerId, String receiverId) async {
    // 1. End Agora session
    await _audioService.endCall();

    // 2. Update Firestore
    await _callService.endCall(callerId, receiverId);

    _isCalling = false;
    notifyListeners();
  }
}
