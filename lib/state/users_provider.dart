import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//A class for managina all user functions
class UsersProvider extends ChangeNotifier {
  List _users = [];
  final _firestore = FirebaseFirestore.instance;
  get users => _users;

  Map<String, dynamic> _currentUserDetails = {};

  Map<String, dynamic> get currentUserDetails => _currentUserDetails;

  void setUserDetails(Map<String, dynamic> userDetails) {
    _currentUserDetails = userDetails;
    notifyListeners();
  }

  //Responsible for assigning a user to be a manager or a normal user
  void assignManager(String id, String currentPosition) async {
    final userDoc = _firestore.collection("users").doc(id);
    final newPosition = currentPosition == 'manager' ? 'normal' : 'manager';
    await userDoc.update({'position': newPosition});
    notifyListeners();
  }

  //A manager can be able to change the department of a user
  void changeDepartment(String id, String newDepartment) {
    _firestore
        .collection("users")
        .doc(id)
        .update({'department': newDepartment});
    notifyListeners();
  }

  //Ability to delete an existing user
  void deleteUser(String id) {
    _firestore.collection("users").doc(id).delete();
    notifyListeners();
  }

  //Displaying all users so that one is able to assign users roles
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final querysnapshot = await _firestore.collection("users").get();
    final users = querysnapshot.docs.map((doc) => doc.data()).toList();
    _users = users;
    return users;
  }
}
