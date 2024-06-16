import 'package:elewa_test/presentation/admin_page.dart';
import 'package:elewa_test/presentation/landing_page.dart';
import 'package:elewa_test/presentation/manager_screen.dart';
import 'package:elewa_test/state/department_provider.dart';
import 'presentation/normal_user_page.dart';
import 'package:elewa_test/state/task_provider.dart';
import 'package:elewa_test/state/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UsersProvider>(create: (_) => UsersProvider()),
        ChangeNotifierProvider<TaskProvider>(create: (_) => TaskProvider()),
        ChangeNotifierProvider<DepartmentProvider>(
            create: (_) => DepartmentProvider()),
      ],
      child: MaterialApp(
        title: 'Team Tasks',
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: messengerKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LandingPage(),
        routes: {
          ManagerScreen.routeName: (context) => const ManagerScreen(),
          AdminPage.routeName: (context) => const AdminPage(),
          NormalUserPage.routename: (context) => const NormalUserPage(),
        },
      ),
    );
  }
}
