import 'package:elewa_test/presentation/widgets/add_department_widget.dart';
import 'package:elewa_test/presentation/widgets/add_task_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../state/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:elewa_test/repository/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManagerScreen extends StatefulWidget {
  static const routeName = "managerScreen";
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  late AnimationController _controller;
  bool isExpanded = false;

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
    Provider.of<UsersProvider>(context, listen: false).getUserDetails();
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
      body: Column(
        children: [
          Text(
              "Welcome ${userDetails["fullName"]}, ${userDetails["position"]}"),
        ],
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
