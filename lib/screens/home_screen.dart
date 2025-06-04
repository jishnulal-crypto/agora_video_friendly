import 'package:agora_video_friendly/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'email@example.com',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await userProvider.signInWithEmailPassword(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),context
                  );
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/userList');
                  }
                } catch (e) {
                  _showError(e.toString());
                }
              },
              child: const Text('Login with Email & Password'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await userProvider.signInWithGoogle(context);
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/userList');
                  }
                } catch (e) {
                  _showError(e.toString());
                }
              },
              child: const Text('Login with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
