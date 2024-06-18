import 'package:elewa_test/presentation/assign_managers.dart';
import 'package:provider/provider.dart';
import 'package:elewa_test/services/auth_service.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  static const routeName = '/AdminPage';
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // final user = Auth().currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // leading: null,
        backgroundColor: Colors.transparent,
        title: const Text('Welcome '),
        actions: [
          TextButton.icon(
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
            },
            label: const Text("Log out"),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: const AllUsersList(),
    );
  }
}
