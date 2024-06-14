import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersProvider extends ChangeNotifier {
  List _users = [];
  final _firestore = FirebaseFirestore.instance;
  get users => _users;

  void assignManager(String id) async {
    final userDoc = _firestore.collection("users").doc(id);
    userDoc.update({'position': 'manager'});
    notifyListeners();
  }

  void changeDepartment(String id, String newDepartment) {
    _firestore
        .collection("users")
        .doc(id)
        .update({'department': newDepartment});
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final querysnapshot = await _firestore.collection("users").get();
    final users = querysnapshot.docs.map((doc) => doc.data()).toList();
    _users = users;
    return users;
  }
}
