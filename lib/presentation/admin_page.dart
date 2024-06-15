import 'package:elewa_test/presentation/assign_managers.dart';
import 'package:elewa_test/repository/firebase_auth.dart';
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
        //  title: Text('Welcome $user'),
      ),
      body: const AllUsersList(),
    );
  }
}
