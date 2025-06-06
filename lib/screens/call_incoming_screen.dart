import 'package:flutter/material.dart';

class CallScreenIncomingReceiver extends StatelessWidget {
  final String callerName;
  final String callType; // "audio" or "video"
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const CallScreenIncomingReceiver({
    Key? key,
    required this.callerName,
    required this.callType,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isVideo = callType == 'video';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            Text(
              isVideo ? 'Incoming Video Call' : 'Incoming Audio Call',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 12),

            Text(
              callerName,
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            Icon(
              isVideo ? Icons.videocam : Icons.call,
              color: isVideo ? Colors.blue : Colors.green,
              size: 80,
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decline Button
                FloatingActionButton(
                  heroTag: "decline",
                  onPressed: onDecline,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end),
                ),

                // Accept Button
                FloatingActionButton(
                  heroTag: "accept",
                  onPressed: onAccept,
                  backgroundColor: Colors.green,
                  child: Icon(isVideo ? Icons.videocam : Icons.call),
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
