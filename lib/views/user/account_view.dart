import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:myapp/backend_integrations/github.dart';
import 'package:myapp/backend_integrations/google.dart';
import 'package:myapp/services/loading_service.dart';

class AccountView extends StatefulWidget {
  final ScrollController? scrollController;
  const AccountView({super.key, this.scrollController});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  // TODO: This is a local state for demonstration. For a real app,
  // this user data should come from a proper state management solution.
  String _userName = 'User Name';
  String _email = 'user.name@example.com';
  String? _nickname = 'user_nickname';
  String? _address = '123 Main St, Anytown, USA';
  DateTime _dateOfBirth = DateTime(1990, 1, 1);

  // State for inline editing
  String _currentlyEditing = ''; // Holds the key of the field being edited
  final _textEditingController = TextEditingController();

  Future<void> _connectToGoogle(BuildContext context) async {
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
  }

  Future<void> _connectToGitHub(BuildContext context) async {
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
  }

  void _logout(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _changeProfilePicture() {
    Fluttertoast.showToast(msg: "Changing profile picture is not yet implemented.");
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: const Text('This functionality is not yet implemented.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handleEdit(String fieldKey, String currentValue) {
    setState(() {
      _currentlyEditing = fieldKey;
      _textEditingController.text = currentValue;
    });
  }

  void _handleSave(String fieldKey) {
    setState(() {
      String fieldLabel = '';
      switch (fieldKey) {
        case 'name':
          _userName = _textEditingController.text;
          fieldLabel = 'Name';
          break;
        case 'email':
          _email = _textEditingController.text;
          fieldLabel = 'Email';
          break;
        case 'nickname':
          _nickname = _textEditingController.text;
          fieldLabel = 'Nickname';
          break;
        case 'address':
          _address = _textEditingController.text;
          fieldLabel = 'Address';
          break;
      }
      _currentlyEditing = '';
      Fluttertoast.showToast(msg: "$fieldLabel updated.");
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (newDate != null) {
      setState(() {
        _dateOfBirth = newDate;
        Fluttertoast.showToast(msg: "Birthday updated.");
      });
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        controller: widget.scrollController,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _changeProfilePicture,
            child: const CircleAvatar(
              radius: 50,
              child: Icon(Icons.camera_alt, size: 30),
            ),
          ),
          const SizedBox(height: 24),
          _buildEditableRow(
            context,
            fieldKey: 'name',
            label: 'Name',
            value: _userName,
          ),
          _buildEditableRow(
            context,
            fieldKey: 'nickname',
            label: 'Nickname',
            value: _nickname ?? 'N/A',
          ),
          _buildEditableRow(
            context,
            fieldKey: 'email',
            label: 'Email',
            value: _email,
          ),
          _buildEditableRow(
            context,
            fieldKey: 'address',
            label: 'Address',
            value: _address ?? 'N/A',
          ),
          _buildDateRow(context),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () => _showChangePasswordDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(BuildContext context, {required String fieldKey, required String label, required String value}) {
    bool isEditing = _currentlyEditing == fieldKey;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: _textEditingController,
                    autofocus: true,
                  )
                : Text(value),
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit, size: 20),
            onPressed: () {
              if (isEditing) {
                _handleSave(fieldKey);
              } else {
                _handleEdit(fieldKey, value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 80, child: Text('Birthday', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(DateFormat.yMMMd().format(_dateOfBirth))),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _pickDate(context),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationsPage(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.cloud),
          title: const Text('Google Drive'),
          subtitle: const Text('Sync your data with Google Drive'),
          trailing: ElevatedButton(
            onPressed: () => _connectToGoogle(context),
            child: const Text('Connect'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.grain),
          title: const Text('GitHub'),
          subtitle: const Text('Sync your data with a private Gist'),
          trailing: ElevatedButton(
            onPressed: () => _connectToGitHub(context),
            child: const Text('Connect'),
          ),
        ),
      ],
    );
  }
}