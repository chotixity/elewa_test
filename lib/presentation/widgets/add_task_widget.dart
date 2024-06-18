import 'package:elewa_test/models/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/users_provider.dart';

class AddTaskWidget extends StatefulWidget {
  const AddTaskWidget({super.key});

  @override
  State<AddTaskWidget> createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends State<AddTaskWidget> {
  final _taskForm = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  String? _selectedUserId;

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _dueDate = pickedDate;
      });
    });
  }

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
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            Consumer<UsersProvider>(
              // Using Consumer to listen to changes
              builder: (ctx, usersProvider, _) => FutureBuilder<List<User>>(
                future: usersProvider.getAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (!snapshot.hasData) {
                    return const Text('No users available');
                  } else {
                    var filteredUsers = snapshot.data!
                        .where((user) => user.position == 'normal')
                        .toList();
                    return DropdownButtonFormField<String>(
                      value: _selectedUserId,
                      onChanged: (value) =>
                          setState(() => _selectedUserId = value),
                      items: filteredUsers
                          .map<DropdownMenuItem<String>>(
                            (user) => DropdownMenuItem<String>(
                              value: user.id,
                              child: Text(user.fullName),
                            ),
                          )
                          .toList(),
                      decoration:
                          const InputDecoration(labelText: 'Assign User'),
                    );
                  }
                },
              ),
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Due Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _presentDatePicker,
                ),
              ),
              controller: TextEditingController(
                text: _dueDate == null
                    ? null
                    : DateFormat('yyyy-MM-dd').format(_dueDate!),
              ),
              readOnly: true, // Prevents keyboard from appearing
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please choose a due date';
                }
                return null;
              },
              onTap: _presentDatePicker,
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
              if (_selectedUserId == null || _dueDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill in all the fields')),
                );
                return;
              }
              // Assuming addTask method is updated to accept DateTime
              Provider.of<TaskProvider>(context, listen: false).addTask(
                _selectedUserId!,
                _titleController.text,
                _descriptionController.text,
                Progress.assigned,
                _dueDate!,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
