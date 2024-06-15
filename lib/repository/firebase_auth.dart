import 'package:elewa_test/presentation/admin_page.dart';
import 'package:elewa_test/presentation/manager_screen.dart';
import 'package:elewa_test/presentation/normal_user_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../models/user.dart' as localUser;

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> _currentUserDetails = {};

  get currentUserDetails => _currentUserDetails;

  // Sign up with email and password
  Future<User?> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      // Store user data in Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          "id": user.uid,
          "fullName": fullName,
          "position": "normal",
          "department": null
        });
        // Navigate to HomePage on success
        _authNavOptions();
      }
      return user;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'The email address is already in use by another account.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        default:
          errorMessage = 'An unknown error occurred.';
      }
      // Show error message to the user
      messengerKey.currentState!
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      // Generic error handling
      messengerKey.currentState!.showSnackBar(const SnackBar(
          content: Text('An error occurred. Please try again.')));
      print(e);
    }
    return null;
  }

  // Sign in with email and password
  Future<User?> signIn(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      // Navigate to HomePage on success
      _authNavOptions();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        default:
          errorMessage = 'An unknown error occurred.';
      }
      // Show error message to the user
      messengerKey.currentState!
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      // Generic error handling
      messengerKey.currentState!.showSnackBar(const SnackBar(
          content: Text('An error occurred. Please try again.')));
      print(e);
    }
    return null;
  }

  // Reset password
  Future<void> resetPassword(
    String email,
  ) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      messengerKey.currentState!.showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'An unknown error occurred.';
      }
      // Show error message to the user
      messengerKey.currentState!
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      // Generic error handling
      messengerKey.currentState!.showSnackBar(const SnackBar(
          content: Text('An error occurred. Please try again.')));
      print(e);
    }
  }

  // Method to get current user details from Firestore
  Future<localUser.User?> getUserDetails() async {
    User? user = _firebaseAuth.currentUser;
    print(user);
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.data() != null) {
          _currentUserDetails = userDoc.data() as Map<String, dynamic>;
          return localUser.User.fromJson(
              userDoc.data()! as Map<String, dynamic>);
        }
      } catch (e) {
        print('Failed to fetch user details: $e');
      }
    }
    return null;
  }

//A function to decide on  which screen to navigate to based on the user
  void _authNavOptions() async {
    await getUserDetails();
    debugPrint(_currentUserDetails.toString());
    if (_currentUserDetails.isEmpty) {
      return;
    } else if (_currentUserDetails['position'] == 'manager') {
      navigatorKey.currentState!.pushReplacementNamed(ManagerScreen.routeName);
    } else if (_currentUserDetails['position'] == 'normal') {
      navigatorKey.currentState!.pushReplacementNamed(NormalUserPage.routename);
    } else {
      navigatorKey.currentState!.pushReplacementNamed(AdminPage.routeName);
    }
  }
}
