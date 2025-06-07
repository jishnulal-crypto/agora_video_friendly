import 'package:agora_video_friendly/screens/call_incoming_screen.dart';
import 'package:agora_video_friendly/screens/call_initiation_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/user_list_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/userList':
        return MaterialPageRoute(builder: (_) => const UserListScreen());
      

      case '/callInitiation':
        if (args is Map<String, dynamic>) {
          final callerId = args['callerId'] as String? ?? '';
          final receiverId = args['receiverId'] as String? ?? '';
          final userName = args['userName'] as String? ?? 'Unknown';
          final photoUrl = args['photoUrl'] as String? ?? '';

          return MaterialPageRoute(
            builder: (_) => CallInitiationScreen(
              callerId: callerId,
              receiverId: receiverId,
              userName: userName,
              photoUrl: photoUrl,
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Invalid arguments for /callInitiation')),
          ),
        );

      case '/callScreen':
  final uri = Uri.parse(settings.name ?? '');

  final callType = uri.queryParameters['type'] ?? 'audio';
  final callerName = uri.queryParameters['callerName'] ?? 'Unknown';
  final callerId = uri.queryParameters['callerId'] ?? '';
  final receiverId = uri.queryParameters['receiverId'] ?? '';
  final isVideo = uri.queryParameters['isVideo'] == 'true';
  final channelId = uri.queryParameters['channelId'] ?? '';

  return MaterialPageRoute(
    builder: (_) => CallScreenIncomingReceiver(
      onAccept: () {
        // TODO: handle accept logic, like joining Agora channel
      },
      onDecline: () {
        // TODO: handle decline logic, like ending call or sending signal
      },
      callType: callType,
      callerName: callerName,
      callerId: callerId,
      receiverId: receiverId,
      isVideo: isVideo,
      channelId: channelId,
    ),
  );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
