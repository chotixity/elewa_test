import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  static const routeName = '/Homepage';
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Welcome'),
      ),
    );
  }
}
