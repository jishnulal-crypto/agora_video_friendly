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
          final userName = args['userName'] as String? ?? 'Unknown';
          final photoUrl = args['photoUrl'] as String? ?? '';

          return MaterialPageRoute(
            builder: (_) => CallInitiationScreen(
              userName: userName,
              photoUrl: photoUrl,
            ),
          );
        }
        // If args are not correct, show error screen or fallback
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Invalid arguments for /callInitiation')),
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
