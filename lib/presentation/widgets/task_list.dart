import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';

class TaskListScreen extends StatelessWidget {
  final String userId;

  const TaskListScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: Provider.of<TaskProvider>(context).getUserTasks(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading tasks'));
        }

        final tasks = snapshot.data ?? [];

        // Filter tasks to show only those where progress is not "done"
        final filteredTasks =
            tasks.where((task) => task.progress != Progress.done).toList();

        if (filteredTasks.isEmpty) {
          return const Center(child: Text('No tasks assigned'));
        }

        return ListView.builder(
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return TaskCard(task: task);
          },
        );
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(task.description),
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
  }
}
