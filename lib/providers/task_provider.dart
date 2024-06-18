import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elewa_test/main.dart';
import 'package:flutter/material.dart';
import './users_provider.dart';
import '../models/task.dart';
import '../services/email_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EmailService _emailService = EmailService();

  // Create a task
  Future<void> addTask(
      String userId,
      String title,
      String description,
      Progress progress,
      DateTime dueDate,
      isRecurring,
      Duration? interval) async {
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
      _sendNotification(task);
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

  // Method to get tasks for a specific department
  Future<List<Task>> getTasksByDepartment(String departmentId) async {
    try {
      QuerySnapshot taskSnapshot = await _firestore.collection('tasks').get();
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('department', isEqualTo: departmentId)
          .get();

      List<String> userIds = userSnapshot.docs.map((doc) => doc.id).toList();

      List<Task> tasks = taskSnapshot.docs
          .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
          .where((task) => userIds.contains(task.userId))
          .toList();

      return tasks;
    } catch (e) {
      return [];
    }
  }

  //Updating a task
  Future<void> updateTask(
      String taskId,
      String userId,
      String title,
      String description,
      Progress progress,
      DateTime dueDate,
      bool isRecurring,
      Duration? interval) async {
    try {
      final taskDoc = _firestore.collection("tasks").doc(taskId);
      await taskDoc.update({
        'userId': userId,
        'title': title,
        'description': description,
        'progress': progress.toString().split('.').last,
        'dueDate': dueDate,
        'isRecurring': isRecurring,
        'interval': interval?.inDays,
      });
      notifyListeners();
    } catch (e) {
      messengerKey.currentState!
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Update a task progress
  Future<void> updateTaskProgress(String taskId, Progress progress) async {
    try {
      final taskDoc = _firestore.collection('tasks').doc(taskId);
      final taskSnapshot = await taskDoc.get();

      if (!taskSnapshot.exists) {
        throw Exception('Task not found');
      }

      final taskData = taskSnapshot.data()!;
      final task = Task.fromJson(taskData);

      // If the task is marked as done and it's recurring, create a new task for the next interval
      if (progress == Progress.done &&
          task.isRecurring &&
          task.interval != null) {
        final newDueDate = task.dueDate.add(task.interval!);
        await addTask(
          task.userId,
          task.title,
          task.description,
          Progress.assigned,
          newDueDate,
          task.isRecurring,
          task.interval,
        );
      }
      // Update the original task's progress
      await taskDoc.update({
        'progress': progress.toString().split('.').last,
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
      messengerKey.currentState!
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Method to get all tasks
  Future<List<Task>> getAllTasks() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('tasks').get();
      List<Task> tasks = snapshot.docs
          .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return tasks;
    } catch (e) {
      print('Error getting all tasks: $e');
      return [];
    }
  }

  //Sending email notifications
  Future<void> _sendNotification(Task task) async {
    final usersProvider = UsersProvider();
    final allUsers = await usersProvider.getAllUsers();
    final assignedUser = allUsers.firstWhere((user) => user.id == task.userId);
    final managers =
        allUsers.where((user) => user.position == 'manager').toList();

    final subject = 'Task Notification: ${task.title}';
    final body = '''
    Task Details:
    Title: ${task.title}
    Description: ${task.description}
    Due Date: ${task.dueDate}
    ''';

    await _emailService.sendTaskNotification(assignedUser.email, subject, body);
    for (var manager in managers) {
      await _emailService.sendTaskNotification(manager.email, subject, body);
    }
  }
}
