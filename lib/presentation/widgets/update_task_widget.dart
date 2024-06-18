import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:elewa_test/models/task.dart';
import 'package:elewa_test/models/user.dart';
import 'package:elewa_test/providers/task_provider.dart';
import 'package:elewa_test/providers/users_provider.dart';

class UpdateTaskWidget extends StatefulWidget {
  final Task task;

  const UpdateTaskWidget({super.key, required this.task});

  @override
  State<UpdateTaskWidget> createState() => _UpdateTaskWidgetState();
}

class _UpdateTaskWidgetState extends State<UpdateTaskWidget> {
  final _taskForm = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  String? _selectedUserId;
  bool _isRecurring = false;
  Duration? _interval;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _dueDate = widget.task.dueDate;
    _selectedUserId = widget.task.userId;
    _isRecurring = widget.task.isRecurring;
    _interval = widget.task.interval;
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
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
      title: const Text('Update Task'),
      content: Form(
        key: _taskForm,
        child: SingleChildScrollView(
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
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please choose a due date';
                  }
                  return null;
                },
                onTap: _presentDatePicker,
              ),
              SwitchListTile(
                title: const Text('Recurring Task'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                    if (!_isRecurring) _interval = null;
                  });
                },
              ),
              if (_isRecurring)
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Recurring Interval (in days)'),
                  keyboardType: TextInputType.number,
                  initialValue: _interval?.inDays.toString(),
                  validator: (value) {
                    if (_isRecurring && (value == null || value.isEmpty)) {
                      return 'Please enter an interval';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _interval = Duration(days: int.parse(value));
                  },
                ),
            ],
          ),
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
              Provider.of<TaskProvider>(context, listen: false).updateTask(
                widget.task.taskId,
                _selectedUserId!,
                _titleController.text,
                _descriptionController.text,
                widget.task.progress,
                _dueDate!,
                _isRecurring,
                _interval,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
