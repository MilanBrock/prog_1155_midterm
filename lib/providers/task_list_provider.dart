import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prog_1155_midterm/models/task.dart';
import 'package:prog_1155_midterm/services/database_operations.dart';
import 'package:prog_1155_midterm/services/encrypted_database_operations.dart';

// Storing the tasks for updating the task list
class PublicTaskListNotifier extends StateNotifier<List<Task>> {
  PublicTaskListNotifier() : super([]) {
    loadTasks();
  }

  Future<void> loadTasks({String sortBy = 'dueDate'}) async {
    final tasks = await DBOperations.getTasks(sortBy: sortBy);
    state = tasks;
  }

  Future<void> addTask(Task task, {String sortBy = 'dueDate'}) async {
    await DBOperations.insertTask(task);
    await loadTasks(sortBy: sortBy);
  }

  Future<void> updateTask(Task task, {String sortBy = 'dueDate'}) async {
    await DBOperations.updateTask(task);
    await loadTasks(sortBy: sortBy);
  }

  Future<void> deleteTask(int id, {String sortBy = 'dueDate'}) async {
    await DBOperations.deleteTask(id);
    await loadTasks(sortBy: sortBy);
  }
}

// Global Riverpod provider
final publicTaskListProvider =
StateNotifierProvider<PublicTaskListNotifier, List<Task>>((ref) {
  return PublicTaskListNotifier();
});



// Storing the tasks for updating the task list
class PrivateTaskListNotifier extends StateNotifier<List<Task>> {
  PrivateTaskListNotifier() : super([]) {
    loadTasks();
  }

  Future<void> loadTasks({String sortBy = 'dueDate'}) async {
    final tasks = await EncryptedDBOperations.instance.getTasks(sortBy: sortBy);
    state = tasks;
  }

  Future<void> addTask(Task task, {String sortBy = 'dueDate'}) async {
    await EncryptedDBOperations.instance.saveTask(task);
    await loadTasks(sortBy: sortBy);
  }

  Future<void> updateTask(Task task, {String sortBy = 'dueDate'}) async {
    await EncryptedDBOperations.instance.saveTask(task);
    await loadTasks(sortBy: sortBy);
  }

  Future<void> deleteTask(String id, {String sortBy = 'dueDate'}) async {
    // Optionally optimistically remove from state:
    state = state.where((t) => t.id.toString() != id).toList();

    await EncryptedDBOperations.instance.deleteTask(id);

    // Update state again to make sure it's in sync
    await loadTasks(sortBy: sortBy);
  }
}

// Global Riverpod provider
final privateTaskListProvider =
StateNotifierProvider<PrivateTaskListNotifier, List<Task>>((ref) {
  return PrivateTaskListNotifier();
});