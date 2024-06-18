import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/main.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //getting the current user
  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get userChanges => _firebaseAuth.userChanges();
  // Stream to listen for auth state changes
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  // Sign up with email and password
  Future<User?> signUp(String email, String password, String fullName) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          "id": user.uid,
          "email": user.email,
          "fullName": fullName,
          "position": "normal",
          "department": null
        });
        return user;
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showError('An error occurred. Please try again.');
    }
    return null;
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showError('An error occurred. Please try again.');
    }
    return null;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _showMessage('Password reset email sent.');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showError('An error occurred. Please try again.');
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Get user details
  Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
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
      case 'user-not-found':
        errorMessage = 'No user found for that email.';
        break;
      case 'wrong-password':
        errorMessage = 'Wrong password provided.';
        break;
      default:
        errorMessage = 'An unknown error occurred.';
    }
    _showError(errorMessage);
  }

  void _showError(String message) {
    messengerKey.currentState!.showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMessage(String message) {
    messengerKey.currentState!.showSnackBar(SnackBar(content: Text(message)));
  }
}
