import 'package:elewa_test/providers/department_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddDepartmentWidget extends StatelessWidget {
  final _departmentNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  AddDepartmentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Department"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(label: Text("Department Name")),
            controller: _departmentNameController,
          ),
          TextField(
            decoration: const InputDecoration(label: Text("Description")),
            controller: _descriptionController,
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            if (_departmentNameController.text.isNotEmpty) {
              Provider.of<DepartmentProvider>(context, listen: false)
                  .addDepartment(_departmentNameController.text,
                      _descriptionController.text);
            }
            Navigator.of(context).pop();
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
