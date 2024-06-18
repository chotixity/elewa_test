import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/users_provider.dart';

class AllUsersList extends StatefulWidget {
  const AllUsersList({super.key});

  @override
  State<AllUsersList> createState() => _AllUsersListState();
}

class _AllUsersListState extends State<AllUsersList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
      ),
      body: Consumer<UsersProvider>(
        builder: (context, provider, _) {
          return FutureBuilder<List<User>>(
            future: provider.getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No users found.'));
              } else {
                final users = snapshot.data!
                    .where((user) => user.position != "admin")
                    .toList();
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final currentPosition = user.position;
                    final newPosition =
                        currentPosition == 'manager' ? 'normal' : 'manager';

                    return ListTile(
                      title: Text(user.fullName),
                      subtitle: Text('Position: ${user.position}'),
                      trailing: SizedBox(
                        width: 250,
                        child: Row(
                          children: [
                            ElevatedButton(
                              child: Text(currentPosition == 'manager'
                                  ? 'Assign Normal'
                                  : 'Assign Manager'),
                              onPressed: () {
                                provider.assignManager(
                                    user.id, currentPosition);
                              },
                            ),
                            const Spacer(),
                            IconButton.filledTonal(
                              onPressed: () {
                                provider.deleteUser(user.id);
                              },
                              icon: const Icon(Icons.delete),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
