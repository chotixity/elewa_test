import 'package:elewa_test/models/task.dart';
import 'package:elewa_test/state/task_provider.dart';
import 'package:elewa_test/state/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddTaskWidget extends StatefulWidget {
  const AddTaskWidget({super.key});

  @override
  State<AddTaskWidget> createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends State<AddTaskWidget> {
  final _taskForm = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: Form(
        key: _taskForm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'please enter a title';
                }
                return null;
              },
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'please enter a description';
                }
                return null;
              },
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: Provider.of<UsersProvider>(context, listen: false)
                  .getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  var filteredUsers = snapshot.data!
                      .where((user) => user['position'] == 'normal')
                      .toList();

                  return DropdownButtonFormField<String>(
                    value: _selectedUserId,
                    onChanged: (value) =>
                        setState(() => _selectedUserId = value),
                    items: filteredUsers
                        .map<DropdownMenuItem<String>>(
                            (user) => DropdownMenuItem<String>(
                                  value: user['id'],
                                  child: Text(user['fullName'] ?? 'No Name'),
                                ))
                        .toList(),
                    decoration: const InputDecoration(labelText: 'Assign User'),
                  );
                } else {
                  return const Text('No users available');
                }
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_taskForm.currentState!.validate()) {
              if (_selectedUserId != null) {
                Provider.of<TaskProvider>(context, listen: false).addTask(
                    _selectedUserId!,
                    _titleController.text,
                    _descriptionController.text,
                    Progress.assigned);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Please select a user to assign the task'),
                ));
              }
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
