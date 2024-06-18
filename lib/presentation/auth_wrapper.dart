import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:elewa_test/repository/auth_service.dart';
import 'package:elewa_test/presentation/manager_screen.dart';
import 'package:elewa_test/presentation/admin_page.dart';
import 'package:elewa_test/presentation/normal_user_page.dart';
import './landing_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: auth.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return const LandingPage();
          } else {
            return FutureBuilder<Map<String, dynamic>?>(
              future: auth.getUserDetails(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    final userDetails = snapshot.data!;
                    if (userDetails['position'] == 'manager') {
                      return const ManagerScreen();
                    } else if (userDetails['position'] == 'normal') {
                      return const NormalUserPage();
                    } else {
                      return const AdminPage();
                    }
                  } else {
                    return const Scaffold(
                        body:
                            Center(child: Text('Error loading user details')));
                  }
                } else {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }
              },
            );
          }
        } else {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
