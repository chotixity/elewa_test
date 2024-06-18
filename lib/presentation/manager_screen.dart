import 'package:elewa_test/repository/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:elewa_test/models/department.dart';
import 'package:elewa_test/presentation/single_department_view.dart';
import 'package:elewa_test/presentation/widgets/add_department_widget.dart';
import 'package:elewa_test/presentation/widgets/add_task_widget.dart';
import 'package:elewa_test/providers/department_provider.dart';
import '../providers/users_provider.dart';
import 'package:provider/provider.dart';

class ManagerScreen extends StatefulWidget {
  static const routeName = "managerScreen";
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedDepartmemtId;
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
    // TODO: implement didChangeDependencies
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
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
                                style: Theme.of(context).textTheme.displaySmall,
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
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No Users available'),
                    );
                  } else {
                    var usersWithoutDepartment = snapshot.data!
                        .where((user) => user.department == null)
                        .toList();
                    return SizedBox(
                      width: MediaQuery.sizeOf(context).width * .4,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: usersWithoutDepartment.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            child: ListTile(
                              title:
                                  Text(usersWithoutDepartment[index].fullName),
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
                                            future:
                                                Provider.of<DepartmentProvider>(
                                                        context)
                                                    .getAllDepartments(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator();
                                              } else if (!snapshot.hasData) {
                                                return const Text(
                                                    'No users available');
                                              } else {
                                                var departments =
                                                    snapshot.data!.toList();
                                                return DropdownButtonFormField<
                                                    String>(
                                                  value: _selectedDepartmemtId,
                                                  onChanged: (value) =>
                                                      setState(() =>
                                                          _selectedDepartmemtId =
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
                                                if (_selectedDepartmemtId !=
                                                    null) {
                                                  Provider.of<UsersProvider>(
                                                          context,
                                                          listen: false)
                                                      .changeDepartment(
                                                          usersWithoutDepartment[
                                                                  index]
                                                              .id,
                                                          _selectedDepartmemtId!);
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              child:
                                                  const Text("Confirm Change"))
                                        ],
                                      );
                                    },
                                  );
                                },
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
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isExpanded)
            FloatingActionButton(
              heroTag: null, // Needed to use multiple FABs
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => const AddTaskWidget());
              },
              child: const Icon(Icons.add_task),
            ),
          if (isExpanded)
            FloatingActionButton(
              heroTag: null, // Needed to use multiple FABs
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
