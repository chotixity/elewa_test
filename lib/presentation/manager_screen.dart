import 'package:elewa_test/presentation/widgets/update_task_widget.dart';
import 'package:elewa_test/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:elewa_test/models/department.dart';
import 'package:elewa_test/presentation/single_department_view.dart';
import 'package:elewa_test/presentation/widgets/add_department_widget.dart';
import 'package:elewa_test/presentation/widgets/add_task_widget.dart';
import 'package:elewa_test/providers/department_provider.dart';
import '../providers/users_provider.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'package:elewa_test/presentation/widgets/summary_dashboard.dart';

class ManagerScreen extends StatefulWidget {
  static const routeName = "managerScreen";
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedDepartmentId;
  late AnimationController _controller;
  bool isExpanded = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      Provider.of<UsersProvider>(context).getUserDetails();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleButtons() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userDetails = Provider.of<UsersProvider>(context).currentUserDetails;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(
          "Welcome ${userDetails["fullName"]}, ${userDetails["position"]}",
          style: TextStyle(
              fontSize: 22, color: Theme.of(context).colorScheme.onSecondary),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
            },
            label: Text(
              "Log Out",
              style: const TextStyle()
                  .copyWith(color: Theme.of(context).colorScheme.onSecondary),
            ),
            icon: Icon(Icons.logout_rounded,
                color: Theme.of(context).colorScheme.onSecondary),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Summary Dashboard",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 20),
              const SummaryDashboard(),
              const SizedBox(height: 20),
              const Text(
                "Departments",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              //Fetch and display the current list of departments for Display
              FutureBuilder(
                future: Provider.of<DepartmentProvider>(context, listen: false)
                    .getAllDepartments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No Departments available'),
                    );
                  } else {
                    var departments = snapshot.data!;
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        childAspectRatio: 16 / 9,
                        maxCrossAxisExtent: 480,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: departments.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const SingleDepartmentView(),
                                settings: RouteSettings(
                                  arguments: departments[index].departmentId,
                                )));
                          },
                          child: Card(
                            elevation: 5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  departments[index].departmentName,
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                                Text(
                                  departments[index].description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Users Without Departments",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Flexible(
                child: FutureBuilder(
                  future: Provider.of<UsersProvider>(context, listen: false)
                      .getAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No Users available'),
                      );
                    } else {
                      var usersWithoutDepartment = snapshot.data!
                          .where((user) => user.department == null)
                          .toList();
                      return SizedBox(
                        width: MediaQuery.sizeOf(context).width > 600
                            ? MediaQuery.sizeOf(context).width * .4
                            : MediaQuery.sizeOf(context).width,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: usersWithoutDepartment.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 4,
                              child: ListTile(
                                title: Text(
                                    usersWithoutDepartment[index].fullName),
                                trailing: TextButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text("New Department"),
                                          content: Consumer<UsersProvider>(
                                            // Using Consumer to listen to changes
                                            builder: (ctx, usersProvider, _) =>
                                                FutureBuilder<List<Department>>(
                                              future: Provider.of<
                                                          DepartmentProvider>(
                                                      context)
                                                  .getAllDepartments(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const CircularProgressIndicator();
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                      'Error: ${snapshot.error}');
                                                } else if (!snapshot.hasData) {
                                                  return const Text(
                                                      'No departments available');
                                                } else {
                                                  var departments =
                                                      snapshot.data!.toList();
                                                  return DropdownButtonFormField<
                                                      String>(
                                                    value:
                                                        _selectedDepartmentId,
                                                    onChanged: (value) =>
                                                        setState(() =>
                                                            _selectedDepartmentId =
                                                                value),
                                                    items: departments
                                                        .map<
                                                            DropdownMenuItem<
                                                                String>>(
                                                          (department) =>
                                                              DropdownMenuItem<
                                                                  String>(
                                                            value: department
                                                                .departmentId,
                                                            child: Text(department
                                                                .departmentName),
                                                          ),
                                                        )
                                                        .toList(),
                                                    decoration:
                                                        const InputDecoration(
                                                            labelText:
                                                                'New Department'),
                                                  );
                                                }
                                              },
                                            ),
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
                                                  if (_selectedDepartmentId !=
                                                      null) {
                                                    Provider.of<UsersProvider>(
                                                            context,
                                                            listen: false)
                                                        .changeDepartment(
                                                            usersWithoutDepartment[
                                                                    index]
                                                                .id,
                                                            _selectedDepartmentId!);
                                                    Navigator.of(context).pop();
                                                  }
                                                },
                                                child: const Text(
                                                    "Confirm Change"))
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text("Assign department"),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),

              const Text(
                "All Tasks",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              FutureBuilder<List<Task>>(
                future: Provider.of<TaskProvider>(context).getAllTasks(),
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
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final isOverdue =
                              task.dueDate.isBefore(DateTime.now()) &&
                                  task.progress != Progress.done;
                          final taskColor = isOverdue
                              ? Colors.red.withOpacity(0.1)
                              : Colors.white;

                          return Card(
                            color: taskColor,
                            child: ListTile(
                                title: Text(task.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task.description),
                                    if (task.isRecurring)
                                      Text(
                                          'Recurring every ${task.interval?.inDays} days'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  UpdateTaskWidget(task: task));
                                        },
                                        icon: const Icon(Icons.edit)),
                                    IconButton(
                                        onPressed: () {
                                          Provider.of<TaskProvider>(context)
                                              .deleteTask(task.taskId);
                                        },
                                        icon: const Icon(Icons.delete))
                                  ],
                                )),
                          );
                        },
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isExpanded)
            FloatingActionButton(
              heroTag: 'addTask', // Unique heroTag for each FAB
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => const AddTaskWidget());
              },
              child: const Icon(Icons.add_task),
            ),
          if (isExpanded)
            FloatingActionButton(
              heroTag: 'addDepartment', // Unique heroTag for each FAB
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AddDepartmentWidget());
              },
              child: const Icon(Icons.group_add),
            ),
          FloatingActionButton.large(
            onPressed: toggleButtons,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _controller,
            ),
          ),
        ],
      ),
    );
  }
}
