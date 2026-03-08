import 'package:flutter/material.dart';
import 'package:myapp/models/task_item.dart';
import 'package:myapp/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final tasks = appState.loggedInUser?.tasks ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks & Projects'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'task') _showTaskEditor(context);
              if (value == 'project') _showProjectEditor(context);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'task', child: Text('Add Task')),
              const PopupMenuItem(value: 'project', child: Text('Add Project')),
            ],
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks or projects yet.'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskItemWidget(item: tasks[index], isRoot: true);
              },
            ),
    );
  }

  void _showTaskEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TaskEditorDialog(),
    );
  }

  void _showProjectEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProjectEditorDialog(),
    );
  }
}

class TaskItemWidget extends StatelessWidget {
  final TaskItem item;
  final bool isRoot;

  const TaskItemWidget({super.key, required this.item, this.isRoot = false});

  @override
  Widget build(BuildContext context) {
    if (item is Task) {
      final task = item as Task;
      return ListTile(
        contentPadding: EdgeInsets.only(left: isRoot ? 16 : 32),
        leading: Icon(Icons.check_circle, color: Provider.of<AppState>(context).loggedInUser?.customCategories.firstWhereOrNull((c) => c.name == task.categoryId)?.color ?? Colors.grey),
        title: Text(task.name),
        subtitle: Text('P${task.priority} • Frog: ${task.froggyness} • ${task.duration.inMinutes}m'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.contactUids.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Chip(
                  label: Text('${task.contactUids.length}'),
                  avatar: const Icon(Icons.people, size: 16),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => Provider.of<AppState>(context, listen: false).deleteItem(item),
            ),
          ],
        ),
      );
    } else if (item is Project) {
      final project = item as Project;
      return ExpansionTile(
        tilePadding: EdgeInsets.only(left: isRoot ? 16 : 32),
        leading: Icon(Icons.folder, color: Provider.of<AppState>(context).loggedInUser?.customCategories.firstWhereOrNull((c) => c.name == project.categoryId)?.color ?? Colors.grey),
        title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Avg P: ${project.priority} • Avg Frog: ${project.froggyness} • Total: ${project.duration.inMinutes}m',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (project.contactUids.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.people, size: 16, color: Theme.of(context).primaryColor),
              ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () => _showSubItemOptions(context, project),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => Provider.of<AppState>(context, listen: false).deleteItem(item),
            ),
          ],
        ),
        children: project.children.map((child) => TaskItemWidget(item: child)).toList(),
      );
    }
    return const SizedBox.shrink();
  }

  void _showSubItemOptions(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.check_box_outlined),
            title: const Text('Add Sub-Task'),
            onTap: () {
              Navigator.pop(context);
              _showTaskEditor(context, parent: project);
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Add Sub-Project'),
            onTap: () {
              Navigator.pop(context);
              _showProjectEditor(context, parent: project);
            },
          ),
        ],
      ),
    );
  }

  void _showTaskEditor(BuildContext context, {Project? parent}) {
    showDialog(
      context: context,
      builder: (context) => TaskEditorDialog(parent: parent),
    );
  }

  void _showProjectEditor(BuildContext context, {Project? parent}) {
    showDialog(
      context: context,
      builder: (context) => ProjectEditorDialog(parent: parent),
    );
  }
}

class TaskEditorDialog extends StatefulWidget {
  final Project? parent;
  const TaskEditorDialog({super.key, this.parent});

  @override
  State<TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<TaskEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _priority = 3;
  int _froggyness = 0;
  int _duration = 30;
  final Set<String> _contactUids = {};
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.parent?.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.parent == null ? 'New Task' : 'New Sub-Task for ${widget.parent!.name}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: Provider.of<AppState>(context).loggedInUser?.customCategories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList() ?? [],
                onChanged: (cat) => setState(() => _categoryId = cat),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
                validator: (val) => val == null || val.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 16),
              const Text('Priority (0-5)'),
              Slider(
                value: _priority.toDouble(),
                min: 0, max: 5, divisions: 5,
                onChanged: (v) => setState(() => _priority = v.round()),
              ),
              const Text('Froggyness (0-5)'),
              Slider(
                value: _froggyness.toDouble(),
                min: 0, max: 5, divisions: 5,
                onChanged: (v) => setState(() => _froggyness = v.round()),
              ),
              TextFormField(
                initialValue: '30',
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => _duration = int.tryParse(v) ?? 30,
              ),
              const Divider(),
              ExpansionTile(
                title: const Text('Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
                children: Provider.of<AppState>(context).loggedInUser!.contacts.map((contact) {
                  return CheckboxListTile(
                    title: Text(contact.fullName),
                    value: _contactUids.contains(contact.uid),
                    onChanged: (v) => setState(() => v! ? _contactUids.add(contact.uid) : _contactUids.remove(contact.uid)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final appState = Provider.of<AppState>(context, listen: false);
              final newTask = Task(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                priority: _priority,
                froggyness: _froggyness,
                duration: Duration(minutes: _duration),
                contactUids: _contactUids.toList(),
                categoryId: _categoryId,
              );

              if (widget.parent != null) {
                final newProject = Project(
                  id: widget.parent!.id,
                  name: widget.parent!.name,
                  description: widget.parent!.description,
                  contactUids: widget.parent!.contactUids,
                  children: [...widget.parent!.children, newTask],
                );
                appState.updateItem<TaskItem>(widget.parent!, newProject);
              } else {
                appState.addItem<TaskItem>(newTask);
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class ProjectEditorDialog extends StatefulWidget {
  final Project? parent;
  const ProjectEditorDialog({super.key, this.parent});

  @override
  State<ProjectEditorDialog> createState() => _ProjectEditorDialogState();
}

class _ProjectEditorDialogState extends State<ProjectEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final Set<String> _contactUids = {};
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.parent?.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.parent == null ? 'New Project' : 'New Sub-Project for ${widget.parent!.name}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: Provider.of<AppState>(context).loggedInUser?.customCategories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList() ?? [],
                onChanged: (cat) => setState(() => _categoryId = cat),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
                validator: (val) => val == null || val.isEmpty ? 'Enter a name' : null,
              ),
              const Divider(),
              ExpansionTile(
                title: const Text('Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
                children: Provider.of<AppState>(context).loggedInUser!.contacts.map((contact) {
                  return CheckboxListTile(
                    title: Text(contact.fullName),
                    value: _contactUids.contains(contact.uid),
                    onChanged: (v) => setState(() => v! ? _contactUids.add(contact.uid) : _contactUids.remove(contact.uid)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final appState = Provider.of<AppState>(context, listen: false);
              final newProj = Project(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                contactUids: _contactUids.toList(),
                categoryId: _categoryId,
              );

              if (widget.parent != null) {
                final updatedParent = Project(
                  id: widget.parent!.id,
                  name: widget.parent!.name,
                  description: widget.parent!.description,
                  contactUids: widget.parent!.contactUids,
                  children: [...widget.parent!.children, newProj],
                );
                appState.updateItem<TaskItem>(widget.parent!, updatedParent);
              } else {
                appState.addItem<TaskItem>(newProj);
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
