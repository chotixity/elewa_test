import 'package:elewa_test/state/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllUsersList extends StatefulWidget {
  const AllUsersList({super.key});

  @override
  State<AllUsersList> createState() => _AllUsersListState();
}

class _AllUsersListState extends State<AllUsersList> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UsersProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: provider.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final currentPosition = user['position'] ?? 'normal';
                final newPosition =
                    currentPosition == 'manager' ? 'normal' : 'manager';

                return ListTile(
                  title: Text(user['fullName'] ?? 'No Name'),
                  subtitle:
                      Text('Position: ${user['position']}' ?? 'No Position'),
                  trailing: SizedBox(
                    width: 250,
                    child: Row(
                      children: [
                        ElevatedButton(
                          child: Text(currentPosition == 'manager'
                              ? 'Assign Normal'
                              : 'Assign Manager'),
                          onPressed: () {
                            provider.assignManager(user['id'], currentPosition);
                          },
                        ),
                        const Spacer(),
                        IconButton.filledTonal(
                          onPressed: () {
                            provider.deleteUser(user['id']);
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
      ),
    );
  }
}
