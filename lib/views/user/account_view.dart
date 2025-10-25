import 'package:flutter/material.dart';

class AccountView extends StatelessWidget {
  final ScrollController? scrollController;
  const AccountView({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              floating: true,
              automaticallyImplyLeading: false,
              title: const Text('Account'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Profile'),
                  Tab(text: 'Integrations'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            _buildProfilePage(context),
            _buildIntegrationsPage(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      // backgroundImage: NetworkImage('https://example.com/user_avatar.png'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'User Name',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'user.name@example.com',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                onTap: () {
                  // Navigate to edit profile screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                onTap: () {
                  // Navigate to change password screen
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  // Handle user logout
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntegrationsPage(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.cloud),
          title: const Text('Cloud Sync Service'),
          subtitle: const Text('Google Drive'),
          onTap: () {
            // Show cloud sync service selection dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('User'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.person),
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'Enter username',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.email),
                            const Text('Email: '),
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'Enter email',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.grain),
          title: const Text('Github Sync Service'),
          // subtitle: const Text('2024'),
          onTap: () {
            // Show sync details
          },
        ),
        ListTile(
          leading: const Icon(Icons.sync),
          title: const Text('Sync Now'),
          onTap: () {
            // Trigger sync action
          },
        ),
      ],
    );
  }
}