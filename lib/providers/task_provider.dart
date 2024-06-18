import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elewa_test/main.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a task
  Future<void> addTask(String userId, String title, String description,
      Progress progress, DateTime dueDate) async {
    try {
      final taskDocRef = _firestore.collection("tasks").doc();
      final task = Task(
        userId: userId,
        taskId: taskDocRef.id,
        dueDate: dueDate,
        title: title,
        description: description,
        progress: progress,
      );
      await taskDocRef.set(task.toJson());
      notifyListeners();
    } catch (e) {
      messengerKey.currentState!
          .showSnackBar(const SnackBar(content: Text("Failed to Add Task")));
    }
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
  Future<void> updateTask(String taskId, String newTitle, String newDescription,
      Progress newProgress, String userId) async {
    try {
      final taskDoc = _firestore.collection("tasks").doc(taskId);
      await taskDoc.update({
        'title': newTitle,
        'description': newDescription,
        'progress': newProgress.toString(),
        'userId': userId
      });
      notifyListeners();
    } catch (e) {
      print("Failed to update task: $e");
      // Handle the error appropriately in your app, e.g., show a snackbar
    }
  }

  Future<void> updateTaskProgress(String taskId, Progress progress) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'progress': progress.toString().split('.').last, // store as string
      });
      notifyListeners();
    } catch (e) {
      print('Error updating task progress: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection("tasks").doc(taskId).delete();
      notifyListeners();
    } catch (e) {
      print("Failed to delete task: $e");
      // Handle the error appropriately in your app, e.g., show a snackbar
    }
  }
}
