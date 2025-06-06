import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_video_friendly/providers/call_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallInitiationScreen extends StatefulWidget {
  final String callerId;
  final String receiverId;
  final String userName;
  final String photoUrl;

  const CallInitiationScreen({
    super.key,
    required this.callerId,
    required this.receiverId,
    required this.userName,
    required this.photoUrl,
  });

  @override
  State<CallInitiationScreen> createState() => _CallInitiationScreenState();
}

class _CallInitiationScreenState extends State<CallInitiationScreen> {
  String _callType = 'none'; // can be 'none', 'audio', or 'video'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child:
            _callType == 'none' ? _buildInitialView() : _buildCallUI(_callType),
      ),
    );
  }

  Widget _buildInitialView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const Spacer(),
        CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(widget.photoUrl),
          backgroundColor: Colors.grey[800],
        ),
        const SizedBox(height: 20),
        Text(
          widget.userName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 60.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCallButton(
                icon: Icons.call,
                label: 'Audio',
                color: Colors.green,
                onTap: () async {
                  setState(() => _callType = 'audio');

                  // i think this code below can be initialized in the statefull class of the videoscreen

                  // await context.read<CallProvider>().startCall(
                  //       callerId: widget.callerId,
                  //       receiverId: widget.receiverId,
                  //       receiverName: widget.userName,
                  //       receiverPhoto: widget.photoUrl,
                  //       isVideo: false,
                  //     );
                },
              ),
              _buildCallButton(
                icon: Icons.videocam,
                label: 'Video',
                color: Colors.blue,
                onTap: () async {
                  setState(() => _callType = 'video');
                  // i think this code below can be initialized in the statefull class of the videoscreen
                  // await context.read<CallProvider>().startCall(
                  //       callerId: widget.callerId,
                  //       receiverId: widget.receiverId,
                  //       receiverName: widget.userName,
                  //       receiverPhoto: widget.photoUrl,
                  //       isVideo: true,
                  //     );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallUI(String type) {
    final isAudio = type == 'audio';

    final String userName = widget.userName;
    final String photoUrl = widget.photoUrl;
    final String smallPreviewPhotoUrl = widget.photoUrl;

    final VoidCallback onEndCall = () async {
      await context.read<CallProvider>().endCall(
        widget.callerId,
        widget.receiverId,
      );
      setState(() => _callType = 'none');
      Navigator.pop(context);
    };

    // Return appropriate screen
    return isAudio
        ? AudioCallScreen(
          photoUrl: widget.photoUrl,
          userName: widget.userName,
          callerId: widget.callerId,
          receiverId: widget.receiverId,

          onEndCall: onEndCall,
        )
        : VideoCallScreen(
          photoUrl: widget.photoUrl,
          userName: widget.userName,
          callerId: widget.callerId,
          receiverId: widget.receiverId,

          onEndCall: onEndCall,
        );
  }

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 32,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}


class VideoCallScreen extends StatefulWidget {
  final String callerId;
  final String receiverId;
  final String userName;
  final String photoUrl;
  final VoidCallback onEndCall;

  const VideoCallScreen({
    super.key,
    required this.callerId,
    required this.receiverId,
    required this.userName,
    required this.photoUrl,
    required this.onEndCall,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool isMuted = false;
  bool isFrontCamera = true;
  int? remoteUid;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    await callProvider.startCall(
      callerId: widget.callerId,
      receiverId: widget.receiverId,
      receiverName: widget.userName,
      receiverPhoto: widget.photoUrl,
      isVideo: true,
    );
    remoteUid = callProvider.remoteUid;

  }

  @override
  void dispose() {
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    callProvider.endCall(widget.callerId, widget.receiverId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main video view (remote user or placeholder)
          Positioned.fill(
            child: remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: Provider.of<CallProvider>(context, listen: false).engine,
                      canvas: VideoCanvas(uid: remoteUid),
                      connection: RtcConnection(channelId: 'test'),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.videocam_off, color: Colors.white30, size: 100),
                  ),
          ),

          // Local preview window
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white70, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: Provider.of<CallProvider>(context, listen: false).engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),
          ),

          // User Info and Buttons
          _buildCallerInfo(),
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildCallerInfo() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 120,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(widget.photoUrl),
              backgroundColor: Colors.grey[700],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircleButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            color: isMuted ? Colors.grey : Colors.blue,
            onTap: () {
              setState(() => isMuted = !isMuted);
              // AgoraRtcEngine.instance.muteLocalAudioStream(isMuted);
            },
          ),
          _buildCircleButton(
            icon: Icons.call_end,
            color: Colors.red,
            onTap: widget.onEndCall,
          ),
          _buildCircleButton(
            icon: Icons.cameraswitch,
            color: Colors.orange,
            onTap: () async {
              // await AgoraRtcEngine.instance.switchCamera();
              setState(() => isFrontCamera = !isFrontCamera);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 30,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}


class AudioCallScreen extends StatefulWidget {
  final String callerId;
  final String receiverId;
  final String userName;
  final String photoUrl;
  final VoidCallback onEndCall;

  const AudioCallScreen({
    super.key,
    required this.callerId,
    required this.receiverId,
    required this.userName,
    required this.photoUrl,
    required this.onEndCall,
  });

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    _initiateCall();
  }

  Future<void> _initiateCall() async {
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    await callProvider.startCall(
      callerId: widget.callerId,
      receiverId: widget.receiverId,
      receiverName: 'receiver B',
      receiverPhoto: 'receiver photo',
      isVideo: false,
    );
  }

  @override
  void dispose() {
    _endCall();
    super.dispose();
  }

  void _endCall() {
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    callProvider.endCall(widget.callerId, widget.receiverId);
    widget.onEndCall();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 40),
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(widget.photoUrl),
            backgroundColor: Colors.grey[800],
          ),
          const SizedBox(height: 24),
          const Text(
            'Calling',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            widget.photoUrl,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircleButton(
                  icon: Icons.volume_up,
                  color: Colors.green,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Audio toggled')),
                    );
                  },
                ),
                _buildCircleButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: _endCall,
                ),
                _buildCircleButton(
                  icon: isMuted ? Icons.mic_off : Icons.mic,
                  color: isMuted ? Colors.grey : Colors.blue,
                  onTap: _toggleMute,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 30,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  void _toggleMute() async {
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    setState(() {
      isMuted = !isMuted;
    });
    // await callProvider.mute(isMuted); // Accessing the service directly
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(isMuted ? 'Muted' : 'Unmuted')));
  }
}

Widget _buildCircleButton({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: CircleAvatar(
      radius: 30,
      backgroundColor: color,
      child: Icon(icon, color: Colors.white, size: 28),
    ),
  );
}
