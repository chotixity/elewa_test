import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/department.dart';
import '../providers/task_provider.dart';
import '../providers/department_provider.dart';
import '../providers/users_provider.dart';

class SingleDepartmentView extends StatefulWidget {
  static const routeName = 'singleDepartmentView';
  const SingleDepartmentView({super.key});

  @override
  State<SingleDepartmentView> createState() => _SingleDepartmentViewState();
}

class _SingleDepartmentViewState extends State<SingleDepartmentView> {
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _selectedDepartmemtId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _isInitialized = true;
      final departmentId =
          ModalRoute.of(context)?.settings.arguments as String?;
      if (departmentId != null) {
        Provider.of<DepartmentProvider>(context, listen: false)
            .getDepartmentDetails(departmentId)
            .then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final departmentDetails =
        Provider.of<DepartmentProvider>(context).departmentDetails;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : departmentDetails == null
              ? const Center(child: Text('Department not found'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'Department Name: ${departmentDetails.departmentName}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: FutureBuilder(
                          future:
                              Provider.of<UsersProvider>(context, listen: false)
                                  .getAllUsers(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text('No Users available'),
                              );
                            } else {
                              var departmentUsers = snapshot.data!
                                  .where((user) =>
                                      user.department ==
                                      departmentDetails.departmentId)
                                  .toList();
                              return Column(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      width:
                                          MediaQuery.sizeOf(context).width * .4,
                                      child: ListView.builder(
                                          itemCount: departmentUsers.length,
                                          itemBuilder: (context, index) {
                                            return SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  .3,
                                              child: Card(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ListTile(
                                                    title: Text(
                                                        departmentUsers[index]
                                                            .fullName),
                                                    trailing: TextButton.icon(
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    "New Department"),
                                                                content: Consumer<
                                                                    UsersProvider>(
                                                                  // Using Consumer to listen to changes
                                                                  builder: (ctx,
                                                                          usersProvider,
                                                                          _) =>
                                                                      FutureBuilder<
                                                                          List<
                                                                              Department>>(
                                                                    future: Provider.of<DepartmentProvider>(
                                                                            context)
                                                                        .getAllDepartments(),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      if (snapshot
                                                                              .connectionState ==
                                                                          ConnectionState
                                                                              .waiting) {
                                                                        return const CircularProgressIndicator();
                                                                      } else if (!snapshot
                                                                          .hasData) {
                                                                        return const Text(
                                                                            'No users available');
                                                                      } else {
                                                                        var departments = snapshot
                                                                            .data!
                                                                            .toList();
                                                                        return DropdownButtonFormField<
                                                                            String>(
                                                                          value:
                                                                              _selectedDepartmemtId,
                                                                          onChanged: (value) =>
                                                                              setState(() => _selectedDepartmemtId = value),
                                                                          items: departments
                                                                              .map<DropdownMenuItem<String>>(
                                                                                (department) => DropdownMenuItem<String>(
                                                                                  value: department.departmentId,
                                                                                  child: Text(department.departmentName),
                                                                                ),
                                                                              )
                                                                              .toList(),
                                                                          decoration:
                                                                              const InputDecoration(labelText: 'New Department'),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child: const Text(
                                                                          "Cancel")),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Provider.of<UsersProvider>(context, listen: false).changeDepartment(
                                                                          departmentUsers[index]
                                                                              .id,
                                                                          _selectedDepartmemtId!);
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: const Text(
                                                                        "Confirm Change"),
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                      },
                                                      label: const Text(
                                                          'Change Department'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  ),
                                  const Text(
                                    "Department Dashboard",
                                  ),
                                  FutureBuilder<List<Task>>(
                                    future: Provider.of<TaskProvider>(context,
                                            listen: false)
                                        .getTasksByDepartment(
                                            departmentDetails.departmentId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return const Center(
                                            child: Text('Error loading tasks'));
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Center(
                                            child: Text('No tasks available'));
                                      } else {
                                        final tasks = snapshot.data!;
                                        final pendingTasks = tasks.where(
                                            (task) =>
                                                task.progress ==
                                                Progress.assigned);
                                        final startedTasks = tasks.where(
                                            (task) =>
                                                task.progress ==
                                                Progress.started);
                                        final doneTasks = tasks.where((task) =>
                                            task.progress == Progress.done);

                                        return Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'Pending Tasks: ${pendingTasks.length}'),
                                              Text(
                                                  'Started Tasks: ${startedTasks.length}'),
                                              Text(
                                                  'Completed Tasks: ${doneTasks.length}'),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
