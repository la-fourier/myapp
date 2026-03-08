import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/backend_integrations/github.dart';
import 'package:myapp/backend_integrations/google.dart';
import 'package:myapp/services/loading_service.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/services/export_service.dart';
import 'package:myapp/widgets/editable_text.dart' as editable_text;

class AccountView extends StatefulWidget {
  final ScrollController? scrollController;
  const AccountView({super.key, this.scrollController});

  @override
  State<AccountView> createState() => AccountViewState();
}

class AccountViewState extends State<AccountView> {
  final ScrollController? scrollController;
  final Key? key;
  Person? _dirtyPerson;

  AccountViewState({this.key, this.scrollController});

  bool _isDirty(Person original) {
    if (_dirtyPerson == null) return false;
    return _dirtyPerson!.fullName != original.fullName ||
           _dirtyPerson!.nickname != original.nickname ||
           _dirtyPerson!.email != original.email ||
           _dirtyPerson!.address != original.address ||
           _dirtyPerson!.dateOfBirth.year != original.dateOfBirth.year ||
           _dirtyPerson!.dateOfBirth.month != original.dateOfBirth.month ||
           _dirtyPerson!.dateOfBirth.day != original.dateOfBirth.day;
  }

  void _saveChanges(BuildContext context, User originalUser) {
    if (_dirtyPerson == null) return;
    
    final appState = Provider.of<AppState>(context, listen: false);
    appState.loggedInUser!.updatePerson(_dirtyPerson!);
    
    final updatedUser = User(
      person: _dirtyPerson!,
      contacts: originalUser.contacts,
      calendar: originalUser.calendar,
      customCategories: originalUser.customCategories,
      bills: originalUser.bills,
      accountBalance: originalUser.accountBalance,
      password: originalUser.password,
    );
    appState.users.add(updatedUser); // This triggers listeners if needed
    
    setState(() {
      _dirtyPerson = null;
    });
    Fluttertoast.showToast(msg: "Profile updated.");
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.loggedInUser;

    if (user == null) {
      return const Center(child: Text('No user logged in.'));
    }

    // Initialize dirty person if not set
    _dirtyPerson ??= Person(
      uid: user.person.uid,
      fullName: user.person.fullName,
      dateOfBirth: user.person.dateOfBirth,
      email: user.person.email,
      nickname: user.person.nickname,
      address: user.person.address,
      profilePictureUrl: user.person.profilePictureUrl,
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: _isDirty(user.person) ? FloatingActionButton.extended(
          onPressed: () => _saveChanges(context, user),
          icon: const Icon(Icons.save),
          label: const Text('Save Changes'),
        ) : null,
        body: NestedScrollView(
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
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: const TabBar(
                        tabs: [
                          Tab(text: 'Profile'),
                          Tab(text: 'Integrations'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildProfilePage(context, appState, user),
              IntegrationsPage(appState: appState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePage(BuildContext context, AppState appState, User user) {
    Future<void> pickDate(BuildContext context) async {
      final newDate = await showDatePicker(
        context: context,
        initialDate: _dirtyPerson!.dateOfBirth,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (newDate != null) {
        setState(() {
          _dirtyPerson = Person(
            uid: _dirtyPerson!.uid,
            fullName: _dirtyPerson!.fullName,
            dateOfBirth: newDate,
            email: _dirtyPerson!.email,
            nickname: _dirtyPerson!.nickname,
            address: _dirtyPerson!.address,
            profilePictureUrl: _dirtyPerson!.profilePictureUrl,
          );
        });
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Fluttertoast.showToast(
              msg: "Changing profile picture is not yet implemented.",
            ),
            child: const CircleAvatar(
              radius: 50,
              child: Icon(Icons.camera_alt, size: 30),
            ),
          ),
          const SizedBox(height: 24),
          _buildEditableRow(
            context,
            'Name',
            _dirtyPerson!.fullName,
            (newValue) {
              setState(() {
                _dirtyPerson = Person(
                  uid: _dirtyPerson!.uid,
                  fullName: newValue,
                  dateOfBirth: _dirtyPerson!.dateOfBirth,
                  nickname: _dirtyPerson!.nickname,
                  profilePictureUrl: _dirtyPerson!.profilePictureUrl,
                  address: _dirtyPerson!.address,
                  email: _dirtyPerson!.email,
                );
              });
            },
          ),
          _buildEditableRow(
            context,
            'Nickname',
            _dirtyPerson!.nickname ?? 'N/A',
            (newValue) {
              setState(() {
                _dirtyPerson = Person(
                  uid: _dirtyPerson!.uid,
                  fullName: _dirtyPerson!.fullName,
                  dateOfBirth: _dirtyPerson!.dateOfBirth,
                  nickname: newValue,
                  profilePictureUrl: _dirtyPerson!.profilePictureUrl,
                  address: _dirtyPerson!.address,
                  email: _dirtyPerson!.email,
                );
              });
            },
          ),
          _buildEditableRow(
            context,
            'Email',
            _dirtyPerson!.email ?? 'N/A',
            (newValue) {
              setState(() {
                _dirtyPerson = Person(
                  uid: _dirtyPerson!.uid,
                  fullName: _dirtyPerson!.fullName,
                  dateOfBirth: _dirtyPerson!.dateOfBirth,
                  nickname: _dirtyPerson!.nickname,
                  profilePictureUrl: _dirtyPerson!.profilePictureUrl,
                  address: _dirtyPerson!.address,
                  email: newValue,
                );
              });
            },
          ),
          _buildEditableRow(
            context,
            'Address',
            _dirtyPerson!.address ?? 'N/A',
            (newValue) {
              setState(() {
                _dirtyPerson = Person(
                  uid: _dirtyPerson!.uid,
                  fullName: _dirtyPerson!.fullName,
                  dateOfBirth: _dirtyPerson!.dateOfBirth,
                  nickname: _dirtyPerson!.nickname,
                  profilePictureUrl: _dirtyPerson!.profilePictureUrl,
                  address: newValue,
                  email: _dirtyPerson!.email,
                );
              });
            },
          ),
          _buildDateRow(context, 'Birthday', _dirtyPerson!.dateOfBirth, pickDate),
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
          const SizedBox(height: 80), // Padding for FAB
        ],
      ),
    );
  }

  Widget _buildEditableRow(
    BuildContext context,
    String label,
    String value,
    Function(String) onSave,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: editable_text.EditableText(
              initialText: value,
              style: Theme.of(context).textTheme.bodyLarge!,
              onSave: onSave,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    String label,
    DateTime value,
    Future<void> Function(BuildContext) pickDate,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => pickDate(context),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  DateFormat.yMMMd().format(value),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IntegrationsPage extends StatefulWidget {
  final AppState appState;
  const IntegrationsPage({super.key, required this.appState});

  @override
  State<IntegrationsPage> createState() => _IntegrationsPageState();
}

class _IntegrationsPageState extends State<IntegrationsPage> {
  final TextEditingController googleController = TextEditingController();
  final TextEditingController githubIdController = TextEditingController();
  final TextEditingController githubSecretController = TextEditingController();
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    final google = await storage.read(key: 'google_web_client_id');
    final githubId = await storage.read(key: 'github_client_id');
    final githubSec = await storage.read(key: 'github_client_secret');
    if (mounted) {
      setState(() {
        googleController.text = google ?? '';
        githubIdController.text = githubId ?? '';
        githubSecretController.text = githubSec ?? '';
      });
    }
  }

  @override
  void dispose() {
    googleController.dispose();
    githubIdController.dispose();
    githubSecretController.dispose();
    super.dispose();
  }
  
  void _showExportDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Export Format'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('CSV'),
                onTap: () {
                  Navigator.of(context).pop();
                  _exportData(context, appState, 'csv');
                },
              ),
              ListTile(
                title: const Text('JSON'),
                onTap: () {
                  Navigator.of(context).pop();
                  _exportData(context, appState, 'json');
                },
              ),
              ListTile(
                title: const Text('TXT'),
                onTap: () {
                  Navigator.of(context).pop();
                  _exportData(context, appState, 'txt');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportData(BuildContext context, AppState appState, String format) async {
    final loadingService = LoadingService();
    loadingService.show();
    try {
      final exportService = ExportService();
      await exportService.exportData(appState, format);
      Fluttertoast.showToast(msg: 'Data exported successfully as $format');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to export data: ${e.toString()}');
    } finally {
      loadingService.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Google Integration',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Enter your Google Web Client ID. OAuth is currently mocked.'),
        TextField(
          controller: googleController,
          decoration: const InputDecoration(
            labelText: 'Google Web Client ID',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) async {
            await storage.write(key: 'google_web_client_id', value: value);
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
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
          icon: const Icon(Icons.cloud),
          label: const Text('Connect to Google Drive'),
        ),
        const Divider(height: 32),
        const Text(
          'GitHub Integration',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Enter your GitHub App details. OAuth is currently mocked.'),
        TextField(
          controller: githubIdController,
          decoration: const InputDecoration(
            labelText: 'GitHub Client ID',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) async {
            await storage.write(key: 'github_client_id', value: value);
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: githubSecretController,
          decoration: const InputDecoration(
            labelText: 'GitHub Client Secret',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          onChanged: (value) async {
            await storage.write(key: 'github_client_secret', value: value);
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
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
          icon: const Icon(Icons.grain),
          label: const Text('Connect to GitHub'),
        ),
        const Divider(height: 32),
        const Text(
          'Export Data',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Download all your data as a single file.'),
        ElevatedButton.icon(
          onPressed: () => _showExportDialog(context, widget.appState),
          icon: const Icon(Icons.download),
          label: const Text('Export'),
        ),
      ],
    );
  }
}
