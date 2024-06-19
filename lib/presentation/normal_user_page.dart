import 'package:elewa_test/presentation/widgets/task_list.dart';
import 'package:elewa_test/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elewa_test/services/auth_service.dart';

class NormalUserPage extends StatefulWidget {
  static const routename = "normalUserPage";
  const NormalUserPage({super.key});

  @override
  State<NormalUserPage> createState() => _NormalUserPageState();
}

class _NormalUserPageState extends State<NormalUserPage> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userProvider = Provider.of<UsersProvider>(context);
    final currentUser = userProvider.currentUserDetails;
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome, Check your tasks below'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
            },
            label: const Text("log out"),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: TaskList(),
      ),
    );
  }
}
