import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioCallService {
  
  static const String appId = "6cfa6bc653894a4a94de3844f8363419";
  static const String tempToken = "007eJxTYHj39Hznlwl7Tl+O6Z1zbHLmol38Dsxb2oy0eawcV137krRagSHVIjHV2CDN0tjM1NDExNIiydjY2MA8NTnZJDnNLNXMNMbQIaMhkJHh5mZDVkYGCATxuRlKEnOynTMS8/JScxgYAO/JI4o="; // Use null if tokenless
  static const String channelName = "talkchannel";

  late final RtcEngine _engine;
  RtcEngine get engine => _engine;

  Future<void> initialize({required Function(int uid) onUserJoined, required Function(int uid) onUserOffline, required bool type}) async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) throw Exception("Microphone permission not granted");

    
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));
    
    if (type) {
      await _engine.enableAudio();
      await _engine.enableVideo();
    }
    await _engine.enableAudio();

    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        print("Joined channel: ${connection.channelId}");
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        print("User joined: $remoteUid");
        onUserJoined(remoteUid);
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        print("User offline: $remoteUid");
        onUserOffline(remoteUid);
      },
    ));
  }

  Future<void> channelConnect({String? channelNameOverride}) async {
    final channel = channelNameOverride ?? channelName;

    await _engine.joinChannel(
      token: tempToken,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<void> mute(bool muted) async {
    await _engine.muteLocalAudioStream(muted);
  }

  Future<void> endCall() async {
    await _engine.leaveChannel();
    await _engine.release();
  }
}
