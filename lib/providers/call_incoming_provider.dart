import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class CallIncomingProvider with ChangeNotifier {
  
  late RtcEngine _engine;
  bool _isInitialized = false;
  static String agoraAppId = '6cfa6bc653894a4a94de3844f8363419';

  RtcEngine get engine => _engine;
  bool get isInitialized => _isInitialized;

  Future<void> initialize({
    
    required String appId,
    required String channelId,
    required bool isVideo,
    String? token,
  }) async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint("Joined channel successfully");
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint("User joined: $remoteUid");
        },
        onUserOffline: (connection, remoteUid, reason) {
          debugPrint("User offline: $remoteUid");
        },
      ),
    );

    if (isVideo) {
      await _engine.enableVideo();
      await _engine.startPreview();
    } else {
      await _engine.enableAudio();
    }

    await _engine.joinChannel(
      token: token!,
      channelId: channelId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> disposeAgora() async {
    await _engine.leaveChannel();
    await _engine.release();
    _isInitialized = false;
    notifyListeners();
  }
}