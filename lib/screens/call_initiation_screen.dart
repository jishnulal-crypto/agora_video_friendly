import 'package:flutter/material.dart';

class CallInitiationScreen extends StatefulWidget {
  final String userName;
  final String photoUrl;

  const CallInitiationScreen({
    super.key,
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
        child: _callType == 'none'
            ? _buildInitialView()
            : _buildCallUI(_callType),
      ),
    );
  }

  Widget _buildInitialView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Back Button
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const Spacer(),
        // Profile Picture
        CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(widget.photoUrl),
          backgroundColor: Colors.grey[800],
        ),
        const SizedBox(height: 20),
        // Username
        Text(
          widget.userName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        // Buttons Row
        Padding(
          padding: const EdgeInsets.only(bottom: 60.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCallButton(
                icon: Icons.call,
                label: 'Audio',
                color: Colors.green,
                onTap: () => setState(() => _callType = 'audio'),
              ),
              _buildCallButton(
                icon: Icons.videocam,
                label: 'Video',
                color: Colors.blue,
                onTap: () => setState(() => _callType = 'video'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallUI(String type) {
    final isAudio = type == 'audio';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAudio ? Icons.call : Icons.videocam,
            size: 80,
            color: isAudio ? Colors.green : Colors.blue,
          ),
          const SizedBox(height: 20),
          Text(
            '${isAudio ? 'Audio' : 'Video'} Call with ${widget.userName}',
            style: const TextStyle(color: Colors.white, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => setState(() => _callType = 'none'),
            icon: const Icon(Icons.call_end),
            label: const Text('End Call'),
          )
        ],
      ),
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
  final String userName;
  final String photoUrl;
  final String smallPreviewPhotoUrl; // photo for small preview (receiver face)
  final VoidCallback onEndCall;

  const VideoCallScreen({
    super.key,
    required this.userName,
    required this.photoUrl,
    required this.smallPreviewPhotoUrl,
    required this.onEndCall,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool isMuted = false;
  bool isAudioEnabled = true;
  bool isFrontCamera = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Front camera preview (placeholder container for now)
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Icon(
                  Icons.videocam,
                  color: Colors.white30,
                  size: 100,
                ),
              ),
              // TODO: Replace above with actual camera preview widget
            ),
          ),

          // 2. Small preview container at top-left (receiver's face)
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black54,
                border: Border.all(color: Colors.white70, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: widget.smallPreviewPhotoUrl.isNotEmpty
                    ? Image.network(
                        widget.smallPreviewPhotoUrl,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Icon(Icons.person, color: Colors.white54, size: 50),
                      ),
              ),
            ),
          ),

          // 3. Caller info (profile + name) near bottom, with rounded container background
          Positioned(
            left: 16,
            right: 16,
            bottom: 120,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Bottom tools container with buttons
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Audio toggle button
                  _buildCircleButton(
                    icon: isAudioEnabled ? Icons.volume_up : Icons.volume_off,
                    color: isAudioEnabled ? Colors.green : Colors.grey,
                    onTap: () {
                      setState(() {
                        isAudioEnabled = !isAudioEnabled;
                      });
                    },
                  ),

                  // Mute toggle button
                  _buildCircleButton(
                    icon: isMuted ? Icons.mic_off : Icons.mic,
                    color: isMuted ? Colors.grey : Colors.blue,
                    onTap: () {
                      setState(() {
                        isMuted = !isMuted;
                      });
                    },
                  ),

                  // End Call button
                  _buildCircleButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    onTap: widget.onEndCall,
                  ),

                  // Switch camera button
                  _buildCircleButton(
                    icon: Icons.cameraswitch,
                    color: Colors.orange,
                    onTap: () {
                      setState(() {
                        isFrontCamera = !isFrontCamera;
                      });
                      // TODO: Add camera switch logic here
                    },
                  ),
                ],
              ),
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
}

class AudioCallScreen extends StatefulWidget {
  final String userName;
  final String photoUrl;
  final VoidCallback onEndCall;

  const AudioCallScreen({
    super.key,
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Profile Picture
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(widget.photoUrl),
            backgroundColor: Colors.grey[800],
          ),

          const SizedBox(height: 24),

          // "Calling" Text
          const Text(
            'Calling',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 8),

          // Username Text
          Text(
            widget.userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          // Bottom buttons row
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Audio toggle button (simulate audio switch)
                _buildCircleButton(
                  icon: Icons.volume_up,
                  color: Colors.green,
                  onTap: () {
                    // You can implement actual audio toggle here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Audio toggled')),
                    );
                  },
                ),

                // End call button
                _buildCircleButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: widget.onEndCall,
                ),

                // Mute toggle button
                _buildCircleButton(
                  icon: isMuted ? Icons.mic_off : Icons.mic,
                  color: isMuted ? Colors.grey : Colors.blue,
                  onTap: () {
                    setState(() {
                      isMuted = !isMuted;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isMuted ? 'Muted' : 'Unmuted'),
                      ),
                    );
                  },
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
}
