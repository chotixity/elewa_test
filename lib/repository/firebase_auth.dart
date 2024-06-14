import 'package:elewa_test/presentation/homepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      // Store user data in Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          "id": user.uid,
          "fullName": fullName,
          "position": "normal",
          "department": null
        });
        // Navigate to HomePage on success
        navigatorKey.currentState!.pushReplacementNamed(Homepage.routeName);
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
      navigatorKey.currentState!.pushReplacementNamed(Homepage.routeName);
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
}
