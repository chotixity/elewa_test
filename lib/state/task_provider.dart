import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a task
  void addTask(
      String userId, String title, String description, Progress progress) {
    final taskDocRef = _firestore.collection("tasks").doc();
    final task = Task(
      userId: userId,
      taskId: taskDocRef.id,
      title: title,
      description: description,
      progress: progress,
    );
    taskDocRef.set(task.toJson());
    notifyListeners();
  }

  // Read tasks for a specific user
  Stream<List<Task>> getUserTasks(String userId) {
    return _firestore
        .collection("tasks")
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList());
  }

  // Update a task
  void updateTask(String taskId, String newTitle, String newDescription,
      Progress newProgress, String userId) {
    final taskDoc = _firestore.collection("tasks").doc(taskId);
    taskDoc.update({
      'title': newTitle,
      'description': newDescription,
      'progress': newProgress.toString(),
      'userId': userId
    });
    notifyListeners();
  }

  // Delete a task
  void deleteTask(String taskId) {
    _firestore.collection("tasks").doc(taskId).delete();
    notifyListeners();
  }
}
