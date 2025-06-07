import 'package:agora_video_friendly/providers/call_incoming_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallScreenIncomingReceiver extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final String callType;
  final String callerName;
  final String callerId;
  final String receiverId;
  final bool isVideo;
  final String channelId;

  const CallScreenIncomingReceiver({
    super.key,
    required this.onAccept,
    required this.onDecline,
    required this.callType,
    required this.callerName,
    required this.callerId,
    required this.receiverId,
    required this.isVideo,
    required this.channelId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: isVideo
            ? VideoCallUI(
              channelId: channelId,
                callerName: callerName,
                onAccept: onAccept,
                onDecline: onDecline,
              )
            : AudioCallUI(
              channelId: channelId,
                callerName: callerName,
                onAccept: onAccept,
                onDecline: onDecline,
              ),
      ),
    );
  }
}


class AudioCallUI extends StatefulWidget {
  final String callerName;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final String channelId;

  const AudioCallUI({
    super.key,
    required this.callerName,
    required this.onAccept,
    required this.onDecline,
    required this.channelId,
  });

  @override
  State<AudioCallUI> createState() => _AudioCallUIState();
}

class _AudioCallUIState extends State<AudioCallUI> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CallIncomingProvider>(context, listen: false).initialize(
        appId: CallIncomingProvider.agoraAppId,
        channelId: widget.channelId,
        isVideo: false,
      );
    });
  }

  @override
  void dispose() {
    Provider.of<CallIncomingProvider>(context, listen: false).disposeAgora();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const Text('Incoming Audio Call', style: TextStyle(color: Colors.white70, fontSize: 18)),
        const SizedBox(height: 12),
        Text(widget.callerName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        const Icon(Icons.call, color: Colors.green, size: 80),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(heroTag: "decline_audio", onPressed: widget.onDecline, backgroundColor: Colors.red, child: const Icon(Icons.call_end)),
            FloatingActionButton(heroTag: "accept_audio", onPressed: widget.onAccept, backgroundColor: Colors.green, child: const Icon(Icons.call)),
          ],
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}

class VideoCallUI extends StatefulWidget {
  final String callerName;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final String channelId;

  const VideoCallUI({
    super.key,
    required this.callerName,
    required this.onAccept,
    required this.onDecline,
    required this.channelId,
  });

  @override
  State<VideoCallUI> createState() => _VideoCallUIState();
}

class _VideoCallUIState extends State<VideoCallUI> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CallIncomingProvider>(context, listen: false).initialize(
        appId:CallIncomingProvider.agoraAppId ,
        channelId: widget.channelId,
        isVideo: true,
      );
    });
  }

  @override
  void dispose() {
    Provider.of<CallIncomingProvider>(context, listen: false).disposeAgora();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Center(child: Text("Video Feed will be here", style: TextStyle(color: Colors.white))),
        Column(
          children: [
            const Spacer(),
            Text(widget.callerName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(heroTag: "decline_video", onPressed: widget.onDecline, backgroundColor: Colors.red, child: const Icon(Icons.call_end)),
                FloatingActionButton(heroTag: "accept_video", onPressed: widget.onAccept, backgroundColor: Colors.blue, child: const Icon(Icons.videocam)),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ],
    );
  }
}

