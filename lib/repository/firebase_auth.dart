import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../presentation/manager_screen.dart';
import '../presentation/admin_page.dart';
import '../presentation/normal_user_page.dart';
import 'package:provider/provider.dart';
import '../state/users_provider.dart';
import '../main.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          "id": user.uid,
          "fullName": fullName,
          "position": "normal",
          "department": null
        });
        //await _setUserDetails(user.uid);
        await _authNavOptions();
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
      messengerKey.currentState!
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
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
      // await _setUserDetails(userCredential.user!.uid);
      await _authNavOptions();
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
      messengerKey.currentState!
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      messengerKey.currentState!.showSnackBar(const SnackBar(
          content: Text('An error occurred. Please try again.')));
      print(e);
    }
    return null;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
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
      messengerKey.currentState!
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      messengerKey.currentState!.showSnackBar(const SnackBar(
          content: Text('An error occurred. Please try again.')));
      print(e);
    }
  }

  // A function to decide on which screen to navigate based on the user
  Future<void> _authNavOptions() async {
    final doc = await _firestore
        .collection("users")
        .doc(_firebaseAuth.currentUser!.uid)
        .get();
    Map<String, dynamic>? userDetails;
    if (doc.data() != null) {
      userDetails = doc.data();
    }

    debugPrint('Current User Details: $userDetails');
    if (userDetails!.isEmpty) {
      debugPrint('User details are empty');
      return;
    } else if (userDetails['position'] == 'manager') {
      debugPrint('Navigating to Manager Screen');
      navigatorKey.currentState!.pushReplacementNamed(ManagerScreen.routeName);
    } else if (userDetails['position'] == 'normal') {
      debugPrint('Navigating to Normal User Page');
      navigatorKey.currentState!.pushReplacementNamed(NormalUserPage.routename);
    } else {
      debugPrint('Navigating to Admin Page');
      navigatorKey.currentState!.pushReplacementNamed(AdminPage.routeName);
    }
  }
}
