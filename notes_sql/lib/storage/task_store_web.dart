import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'task_model.dart';
import 'task_store.dart';

const String _tasksKey = 'notes_sql_tasks';
const String _nextIdKey = 'notes_sql_next_id';

TaskStore createStore() => _SharedPrefsTaskStore();

class _SharedPrefsTaskStore implements TaskStore {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.setInt(_nextIdKey, _prefs!.getInt(_nextIdKey) ?? 1);
  }

  @override
  Future<List<TaskItem>> getTasks() async {
    final SharedPreferences prefs = _prefs!;
    final String? raw = prefs.getString(_tasksKey);
    if (raw == null || raw.isEmpty) {
      return <TaskItem>[];
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    final List<TaskItem> tasks = decoded
        .map((dynamic item) => TaskItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    tasks.sort((TaskItem a, TaskItem b) => b.id.compareTo(a.id));
    return tasks;
  }

  @override
  Future<void> addTask(String name, String description) async {
    final List<TaskItem> tasks = await _readTasksAscending();
    final int id = _prefs!.getInt(_nextIdKey) ?? 1;

    tasks.add(TaskItem(id: id, name: name, description: description));
    await _prefs!.setInt(_nextIdKey, id + 1);
    await _writeTasks(tasks);
  }

  @override
  Future<void> updateTask(int id, String name, String description) async {
    final List<TaskItem> tasks = await _readTasksAscending();
    final int index = tasks.indexWhere((TaskItem task) => task.id == id);
    if (index == -1) {
      return;
    }

    tasks[index] = tasks[index].copyWith(name: name, description: description);
    await _writeTasks(tasks);
  }

  @override
  Future<void> deleteTask(int id) async {
    final List<TaskItem> tasks = await _readTasksAscending();
    tasks.removeWhere((TaskItem task) => task.id == id);
    await _writeTasks(tasks);
  }

  @override
  Future<void> addNotes(int taskId, String notes) async {
    final List<TaskItem> tasks = await _readTasksAscending();
    final int index = tasks.indexWhere((TaskItem task) => task.id == taskId);
    if (index == -1) {
      return;
    }

    tasks[index] = tasks[index].copyWith(description: notes);
    await _writeTasks(tasks);
  }

  Future<List<TaskItem>> _readTasksAscending() async {
    final String? raw = _prefs!.getString(_tasksKey);
    if (raw == null || raw.isEmpty) {
      return <TaskItem>[];
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((dynamic item) => TaskItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeTasks(List<TaskItem> tasks) async {
    final String raw = jsonEncode(
      tasks.map((TaskItem task) => task.toJson()).toList(growable: false),
    );
    await _prefs!.setString(_tasksKey, raw);
  }

  @override
  Future<void> dispose() async {}
}
