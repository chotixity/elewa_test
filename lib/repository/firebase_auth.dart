import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<void> signUp(
      String email, String password, Map<String, dynamic> userData) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      // Store user data in Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .set(userData);
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
      print(e); // Consider handling the error more gracefully
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
