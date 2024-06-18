import 'package:elewa_test/presentation/widgets/task_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elewa_test/providers/task_provider.dart';
import 'package:elewa_test/repository/auth_service.dart';
import '../models/task.dart';

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
        title: const Text('Normal User Page'),
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
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: TaskListScreen(userId: user.uid)),
    );
  }
}
