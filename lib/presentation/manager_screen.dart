import 'package:elewa_test/presentation/add_task_widget.dart';
import 'package:flutter/material.dart';

class ManagerScreen extends StatefulWidget {
  static const routeName = "mangerScreen";
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen>
    with SingleTickerProviderStateMixin {
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
    return Scaffold(
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
                // Perform action for first button
              },
              child: const Icon(Icons.add_task),
            ),
          if (isExpanded)
            FloatingActionButton(
              heroTag: null, // Needed to use multiple FABs
              onPressed: () {
                // Perform action for second button
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
