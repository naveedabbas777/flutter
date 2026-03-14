import 'package:flutter/material.dart';

import 'storage/task_model.dart';
import 'storage/task_store.dart';

void main() {
  runApp(const TaskManagementApp());
}

class TaskManagementApp extends StatelessWidget {
  const TaskManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskStore _taskStore = createTaskStore();
  List<TaskItem> _tasks = <TaskItem>[];

  @override
  void initState() {
    super.initState();
    _initStore();
  }

  Future<void> _initStore() async {
    await _taskStore.init();
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    final List<TaskItem> tasks = await _taskStore.getTasks();
    if (!mounted) {
      return;
    }
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _addTask(String name, String description) async {
    await _taskStore.addTask(name, description);
    await _loadTasks();
  }

  Future<void> _updateTask(int id, String name, String description) async {
    await _taskStore.updateTask(id, name, description);
    await _loadTasks();
  }

  Future<void> _deleteTask(int id) async {
    await _taskStore.deleteTask(id);
    await _loadTasks();
  }

  void _showTaskDialog(
    BuildContext context, {
    int? id,
    String? name,
    String? description,
  }) {
    final TextEditingController nameController = TextEditingController(
      text: name,
    );
    final TextEditingController descriptionController = TextEditingController(
      text: description,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(id == null ? 'Add Task' : 'Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (id == null) {
                  _addTask(nameController.text, descriptionController.text);
                } else {
                  _updateTask(
                    id,
                    nameController.text,
                    descriptionController.text,
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showNotesDialog(BuildContext context, int taskId) {
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Notes'),
          content: TextField(
            controller: notesController,
            decoration: const InputDecoration(labelText: 'Notes'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addNotes(taskId, notesController.text);
                Navigator.pop(context);
              },
              child: const Text('Save Notes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNotes(int taskId, String notes) async {
    await _taskStore.addNotes(taskId, notes);
    await _loadTasks();
  }

  @override
  void dispose() {
    _taskStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Management')),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final TaskItem task = _tasks[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(task.name),
              subtitle: Text(task.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showTaskDialog(
                        context,
                        id: task.id,
                        name: task.name,
                        description: task.description,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteTask(task.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.note_add),
                    onPressed: () {
                      _showNotesDialog(context, task.id);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
