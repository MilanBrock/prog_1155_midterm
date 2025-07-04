import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prog_1155_midterm/models/task.dart';
import 'package:prog_1155_midterm/services/database_operations.dart';

// Storing the tasks for updating the task list
class TaskListNotifier extends StateNotifier<List<Task>> {
  TaskListNotifier() : super([]) {
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
final taskListProvider =
StateNotifierProvider<TaskListNotifier, List<Task>>((ref) {
  return TaskListNotifier();
});
