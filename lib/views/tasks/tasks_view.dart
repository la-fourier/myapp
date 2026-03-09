import 'package:flutter/material.dart';
import 'package:myapp/models/task_item.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/widgets/empty_state_widget.dart';
import 'package:myapp/widgets/shimmer_loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final tasks = appState.loggedInUser?.tasks ?? [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
        ),
        Expanded(
          child: !appState.isInitialized
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  itemBuilder: (context, index) => const SkeletonListTile(),
                )
              : tasks.isEmpty
                  ? EmptyStateWidget(
                      title: 'No tasks or projects',
                      message: 'Organize your work and track your progress.',
                      icon: Icons.assignment_turned_in_outlined,
                      actionLabel: 'Add Task',
                      onAction: () => _showTaskEditor(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: TaskItemWidget(item: tasks[index], isRoot: true),
                        );
                      },
                    ),
        ),
      ],
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
    final theme = Theme.of(context);
    Widget content;
    if (item is Task) {
      final task = item as Task;
      content = ListTile(
        contentPadding: EdgeInsets.only(left: isRoot ? 16 : 32, right: 8),
        leading: Icon(Icons.check_circle, color: Provider.of<AppState>(context).loggedInUser?.customCategories.firstWhereOrNull((c) => c.name == task.categoryId)?.color ?? Colors.grey),
        title: Text(task.name, style: TextStyle(fontWeight: isRoot ? FontWeight.bold : FontWeight.normal)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('P${task.priority} • Frog: ${task.froggyness} • ${task.duration.inMinutes}m'),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: Provider.of<AppState>(context).getTaskProgress(task),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                minHeight: 4,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.contactUids.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.people, size: 16, color: theme.colorScheme.primary),
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showTaskEditor(context, task: task),
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
      content = ExpansionTile(
        tilePadding: EdgeInsets.only(left: isRoot ? 16 : 32, right: 8),
        leading: Icon(Icons.folder, color: Provider.of<AppState>(context).loggedInUser?.customCategories.firstWhereOrNull((c) => c.name == project.categoryId)?.color ?? Colors.grey),
        title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Avg P: ${project.priority} • Avg Frog: ${project.froggyness} • Total: ${project.duration.inMinutes}m',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: Provider.of<AppState>(context).getTaskProgress(project),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                minHeight: 4,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (project.contactUids.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.people, size: 16, color: theme.colorScheme.primary),
              ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () => _showSubItemOptions(context, project),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showProjectEditor(context, project: project),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => Provider.of<AppState>(context, listen: false).deleteItem(item),
            ),
          ],
        ),
        children: project.children.map((child) => TaskItemWidget(item: child)).toList(),
      );
    } else {
      content = const SizedBox.shrink();
    }

    if (isRoot) {
      return Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
        child: content,
      );
    }
    return content;
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

  void _showTaskEditor(BuildContext context, {Project? parent, Task? task}) {
    showDialog(
      context: context,
      builder: (context) => TaskEditorDialog(parent: parent, task: task),
    );
  }

  void _showProjectEditor(BuildContext context, {Project? parent, Project? project}) {
    showDialog(
      context: context,
      builder: (context) => ProjectEditorDialog(parent: parent, project: project),
    );
  }
}

class TaskEditorDialog extends StatefulWidget {
  final Project? parent;
  final Task? task;
  const TaskEditorDialog({super.key, this.parent, this.task});

  @override
  State<TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<TaskEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  int _priority = 3;
  int _froggyness = 0;
  int _duration = 30;
  DateTime? _deadline;
  final Set<String> _contactUids = {};
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.task?.categoryId ?? widget.parent?.categoryId;
    if (widget.task != null) {
      _nameController.text = widget.task!.name;
      _addressController.text = widget.task!.address ?? '';
      _latController.text = widget.task!.location?.latitude.toString() ?? '';
      _lngController.text = widget.task!.location?.longitude.toString() ?? '';
      _priority = widget.task!.priority;
      _froggyness = widget.task!.froggyness;
      _duration = widget.task!.duration.inMinutes;
      _deadline = widget.task!.deadline;
      _contactUids.addAll(widget.task!.contactUids);
    }
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
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address (optional)'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(_deadline != null
                    ? 'Deadline: ${_deadline!.day}.${_deadline!.month}.${_deadline!.year}'
                    : 'Set Deadline (optional)'),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (d != null) setState(() => _deadline = d);
                },
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
                initialValue: _duration.toString(),
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
                id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                priority: _priority,
                froggyness: _froggyness,
                duration: Duration(minutes: _duration),
                deadline: _deadline,
                contactUids: _contactUids.toList(),
                categoryId: _categoryId,
                address: _addressController.text.isEmpty ? null : _addressController.text,
                location: (_latController.text.isNotEmpty && _lngController.text.isNotEmpty)
                    ? LatLng(double.parse(_latController.text), double.parse(_lngController.text))
                    : null,
                sessionIds: widget.task?.sessionIds,
              );

              if (widget.task != null) {
                appState.updateItem<TaskItem>(widget.task!, newTask);
              } else if (widget.parent != null) {
                final newProject = Project(
                  id: widget.parent!.id,
                  name: widget.parent!.name,
                  description: widget.parent!.description,
                  contactUids: widget.parent!.contactUids,
                  children: [...widget.parent!.children, newTask],
                  categoryId: widget.parent!.categoryId,
                );
                appState.updateItem<TaskItem>(widget.parent!, newProject);
              } else {
                appState.addItem<TaskItem>(newTask);
              }
              Navigator.pop(context);
            }
          },
          child: Text(widget.task != null ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

class ProjectEditorDialog extends StatefulWidget {
  final Project? parent;
  final Project? project;
  const ProjectEditorDialog({super.key, this.parent, this.project});

  @override
  State<ProjectEditorDialog> createState() => _ProjectEditorDialogState();
}

class _ProjectEditorDialogState extends State<ProjectEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final Set<String> _contactUids = {};
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _addressController.text = widget.project!.address ?? '';
      _latController.text = widget.project!.location?.latitude.toString() ?? '';
      _lngController.text = widget.project!.location?.longitude.toString() ?? '';
      _contactUids.addAll(widget.project!.contactUids);
      _categoryId = widget.project!.categoryId;
    } else {
      _categoryId = widget.parent?.categoryId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.project != null ? 'Edit Project' : (widget.parent == null ? 'New Project' : 'New Sub-Project for ${widget.parent!.name}')),
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
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address (optional)'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
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
                id: widget.project?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                address: _addressController.text.isEmpty ? null : _addressController.text,
                location: (_latController.text.isNotEmpty && _lngController.text.isNotEmpty)
                    ? LatLng(double.parse(_latController.text), double.parse(_lngController.text))
                    : null,
                contactUids: _contactUids.toList(),
                categoryId: _categoryId,
              );

              if (widget.project != null) {
                appState.updateItem<TaskItem>(widget.project!, newProj);
              } else if (widget.parent != null) {
                final updatedParent = Project(
                  id: widget.parent!.id,
                  name: widget.parent!.name,
                  description: widget.parent!.description,
                  contactUids: widget.parent!.contactUids,
                  children: [...widget.parent!.children, newProj],
                  categoryId: widget.parent!.categoryId,
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
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ShimmerLoadingWidget(
        width: double.infinity,
        height: 72,
        borderRadius: 16,
      ),
    );
  }
}
