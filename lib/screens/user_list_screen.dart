import 'package:agora_video_friendly/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/user_provider.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<UserProvider>().signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading users'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // Filter out the current logged-in user
          final otherUsers =
              docs.where((doc) => doc.id != currentUser?.uid).toList();

          if (otherUsers.isEmpty) {
            return const Center(child: Text('No other users found'));
          }

          return ListView.builder(
            itemCount: otherUsers.length,
            itemBuilder: (context, index) {
              final userData = otherUsers[index].data() as Map<String, dynamic>;
              return ListTile(
                leading:
                    userData['photoURL'] != null
                        ? CircleAvatar(
                          backgroundImage: NetworkImage(userData['photoURL']),
                        )
                        : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(userData['displayName'] ?? 'No name'),
                subtitle: Text(userData['email'] ?? 'No email'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/callInitiation',
                    arguments: {
                      'callerId':currentUser?.uid,
                      'receiverId': otherUsers[index].id, // 👈 Firestore doc ID
                      'userName': userData['displayName'] ?? 'No name',
                      'photoUrl': userData['photoURL'] ?? '',
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
