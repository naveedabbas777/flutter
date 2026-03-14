import 'task_model.dart';
import 'task_store_mobile.dart' if (dart.library.html) 'task_store_web.dart';

abstract class TaskStore {
  Future<void> init();
  Future<List<TaskItem>> getTasks();
  Future<void> addTask(String name, String description);
  Future<void> updateTask(int id, String name, String description);
  Future<void> deleteTask(int id);
  Future<void> addNotes(int taskId, String notes);
  Future<void> dispose();
}

TaskStore createTaskStore() => createStore();
