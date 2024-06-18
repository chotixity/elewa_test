import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elewa_test/models/department.dart';
import 'package:flutter/material.dart';

class DepartmentProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  Department? _departmentDetails;

  Department? get departmentDetails => _departmentDetails;

  void addDepartment(String departmentName, String description) {
    final departmentDocRef = _firestore.collection("departments").doc();
    final department = Department(
        departmentId: departmentDocRef.id,
        departmentName: departmentName,
        description: description);
    departmentDocRef.set(department.toJson());
    notifyListeners();
  }

  Future<List<Department>> getAllDepartments() async {
    try {
      final snapshot = await _firestore.collection("departments").get();
      final departments =
          snapshot.docs.map((doc) => Department.fromJson(doc.data())).toList();
      return departments;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  //getting details for a certain department
  Future<void> getDepartmentDetails(String departmentId) async {
    final docSnapshot =
        await _firestore.collection("departments").doc(departmentId).get();
    if (docSnapshot.exists) {
      final details = Department.fromJson(docSnapshot.data()!);
      _departmentDetails = details;
      notifyListeners();
    } else {
      _departmentDetails = null; // Department not found
      notifyListeners();
    }
  }
}
