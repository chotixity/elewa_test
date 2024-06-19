import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/users_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/department_provider.dart';

class SummaryDashboard extends StatelessWidget {
  const SummaryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchSummaryData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final summaryData = snapshot.data as SummaryData;
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Task Summary',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                _buildPieChart(summaryData),
                const SizedBox(height: 40),
                Text(
                  'Department Performance',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                _buildBarChart(summaryData),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
      },
    );
  }

  Future<SummaryData> _fetchSummaryData(BuildContext context) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final departmentProvider =
        Provider.of<DepartmentProvider>(context, listen: false);
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);

    final tasks = await taskProvider.getAllTasks();
    final departments = await departmentProvider.getAllDepartments();
    final users = await usersProvider.getAllUsers();

    final int totalTasks = tasks.length;
    final int completedTasks =
        tasks.where((task) => task.progress == Progress.done).length;
    final int startedTasks =
        tasks.where((task) => task.progress == Progress.started).length;
    final int assignedTasks =
        tasks.where((task) => task.progress == Progress.assigned).length;

    final Map<String, int> departmentPerformance = {};

    for (var department in departments) {
      final departmentTasks =
          tasks.where((task) => task.userId != null).where((task) {
        final user = users.firstWhere(
          (user) => user.id == task.userId,
          // orElse: () => local_user.User(),
        );
        return user.department == department.departmentId;
      }).length;
      departmentPerformance[department.departmentName] = departmentTasks;
    }

    return SummaryData(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      startedTasks: startedTasks,
      assignedTasks: assignedTasks,
      departmentPerformance: departmentPerformance,
    );
  }

  Widget _buildPieChart(SummaryData summaryData) {
    return Column(
      children: [
        const Text(
          'Task Progress Distribution',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: summaryData.completedTasks.toDouble(),
                  color: Colors.green,
                  title: 'Completed',
                  titleStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                PieChartSectionData(
                  value: summaryData.startedTasks.toDouble(),
                  color: Colors.orange,
                  title: 'Started',
                  titleStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                PieChartSectionData(
                  value: summaryData.assignedTasks.toDouble(),
                  color: Colors.blue,
                  title: 'Not Started',
                  titleStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(SummaryData summaryData) {
    final departmentEntries =
        summaryData.departmentPerformance.entries.toList();
    return Column(
      children: [
        const Text(
          'Tasks by Department',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceEvenly,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  axisNameWidget: Text('Number of Tasks'),
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text('Departments'),
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final department = departmentEntries[value.toInt()].key;
                      return Text(department,
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: departmentEntries.asMap().entries.map((entry) {
                final index = entry.key;
                final count = entry.value.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: count.toDouble(),
                      color: Colors.lightBlueAccent,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class SummaryData {
  final int totalTasks;
  final int completedTasks;
  final int startedTasks;
  final int assignedTasks;
  final Map<String, int> departmentPerformance;

  SummaryData({
    required this.totalTasks,
    required this.completedTasks,
    required this.startedTasks,
    required this.assignedTasks,
    required this.departmentPerformance,
  });
}
