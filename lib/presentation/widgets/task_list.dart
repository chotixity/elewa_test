import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elewa_test/models/task.dart';
import 'package:elewa_test/providers/task_provider.dart';
import '../../services/auth_service.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Center(
        child: Text('User not logged in.'),
      );
    }

    return StreamBuilder<List<Task>>(
      stream: Provider.of<TaskProvider>(context).getUserTasks(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tasks available.'));
        } else {
          final tasks = snapshot.data!
              .where((task) => task.progress != Progress.done)
              .toList();

          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks available.'));
          }

          return SizedBox(
            width: MediaQuery.sizeOf(context).width > 600
                ? MediaQuery.sizeOf(context).width * .6
                : MediaQuery.sizeOf(context).width,
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final isOverdue = task.dueDate.isBefore(DateTime.now()) &&
                    task.progress != Progress.done;
                final taskColor =
                    isOverdue ? Colors.red.withOpacity(0.1) : Colors.white;

                return Card(
                  color: taskColor,
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.description),
                        if (task.isRecurring)
                          Text('Recurring every ${task.interval?.inDays} days'),
                      ],
                    ),
                    trailing: DropdownButton<Progress>(
                      value: task.progress,
                      onChanged: (newProgress) {
                        if (newProgress != null) {
                          Provider.of<TaskProvider>(context, listen: false)
                              .updateTaskProgress(task.taskId, newProgress);
                        }
                      },
                      items: Progress.values.map((Progress progress) {
                        return DropdownMenuItem<Progress>(
                          value: progress,
                          child: Text(progress.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
