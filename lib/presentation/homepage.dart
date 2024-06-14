import 'package:elewa_test/presentation/assign_managers.dart';
import 'package:elewa_test/repository/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  static const routeName = '/Homepage';
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final user = Auth().currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // leading: null,
        backgroundColor: Colors.transparent,
        title: Text('Welcome $user'),
      ),
      body: const AllUsersList(),
    );
  }
}
