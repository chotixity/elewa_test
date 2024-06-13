import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as localUser;

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<void> signUp(String email, String password, String fullName) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      // Store user data in Firestore
      if (user != null) {
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          "id": userCredential.user?.uid,
          "fullName": fullName,
          "position": "normal",
          "department": null
        });
      }
    } catch (e) {
      print(e); // Consider handling the error more gracefully
    }
  }

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e); // Consider handling the error more gracefully
    }
  }
}
