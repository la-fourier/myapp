import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/backend_integrations/github.dart';
import 'package:myapp/backend_integrations/google.dart';
import 'package:myapp/services/loading_service.dart';
import 'package:myapp/models/user.dart';

class AccountView extends StatelessWidget {
  final ScrollController? scrollController;
  const AccountView({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.loggedInUser;

    if (user == null) {
      return const Center(child: Text('No user logged in.'));
    }

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
            _buildProfilePage(context, appState, user),
            _buildIntegrationsPage(context, appState),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage(BuildContext context, AppState appState, User user) {
    final person = user.person;

    void _showEditDialog(String title, String initialValue, Function(String) onSave) {
      final controller = TextEditingController(text: initialValue);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(controller: controller, autofocus: true),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  onSave(controller.text);
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(msg: "${title.split(' ').last} updated.");
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }

    Future<void> _pickDate(BuildContext context) async {
      final newDate = await showDatePicker(
        context: context,
        initialDate: person.dateOfBirth,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (newDate != null) {
        appState.updateUserDateOfBirth(newDate);
        Fluttertoast.showToast(msg: "Birthday updated.");
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Fluttertoast.showToast(msg: "Changing profile picture is not yet implemented."),
            child: const CircleAvatar(
              radius: 50,
              child: Icon(Icons.camera_alt, size: 30),
            ),
          ),
          const SizedBox(height: 24),
          _buildEditableRow(context, 'Name', person.fullName, (newValue) => appState.updateUserName(newValue), _showEditDialog),
          _buildEditableRow(context, 'Nickname', person.nickname ?? 'N/A', (newValue) => appState.updateUserNickname(newValue), _showEditDialog),
          _buildEditableRow(context, 'Email', person.email ?? 'N/A', (newValue) => appState.updateUserEmail(newValue), _showEditDialog),
          _buildEditableRow(context, 'Address', person.address ?? 'N/A', (newValue) => appState.updateUserAddress(newValue), _showEditDialog),
          _buildDateRow(context, 'Birthday', person.dateOfBirth, _pickDate),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () => Fluttertoast.showToast(msg: "Not implemented yet."),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => appState.logout(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(BuildContext context, String label, String value, Function(String) onSave, Function(String, String, Function(String)) showEditDialog) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => showEditDialog('Change $label', value, onSave),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, String label, DateTime value, Future<void> Function(BuildContext) pickDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(DateFormat.yMMMd().format(value))),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => pickDate(context),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationsPage(BuildContext context, AppState appState) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.cloud),
          title: const Text('Google Drive'),
          subtitle: const Text('Sync your data with Google Drive'),
          trailing: ElevatedButton(
            onPressed: () async {
              final loadingService = LoadingService();
              loadingService.show();
              try {
                await GoogleDriveService().connect();
                Fluttertoast.showToast(msg: "Successfully connected to Google Drive");
              } catch (e) {
                Fluttertoast.showToast(msg: "Failed to connect to Google Drive: ${e.toString()}");
              } finally {
                loadingService.hide();
              }
            },
            child: const Text('Connect'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.grain),
          title: const Text('GitHub'),
          subtitle: const Text('Sync your data with a private Gist'),
          trailing: ElevatedButton(
            onPressed: () async {
              final loadingService = LoadingService();
              loadingService.show();
              try {
                await GitHubService().connect();
                Fluttertoast.showToast(msg: "Successfully connected to GitHub");
              } catch (e) {
                Fluttertoast.showToast(msg: "Failed to connect to GitHub: ${e.toString()}");
              } finally {
                loadingService.hide();
              }
            },
            child: const Text('Connect'),
          ),
        ),
      ],
    );
  }
}