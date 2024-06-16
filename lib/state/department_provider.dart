import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elewa_test/models/department.dart';
import 'package:flutter/material.dart';

class DepartmentProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  void addDepartment(String departmentName) {
    final departmentDocRef = _firestore.collection("departments").doc();
    final department = Department(
      departmentId: departmentDocRef.id,
      departmentName: departmentName,
    );
    departmentDocRef.set(department.toJson());
    notifyListeners();
  }
}
