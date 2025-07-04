import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prog_1155_midterm/models/task.dart';
import 'package:prog_1155_midterm/providers/task_list_provider.dart';
import 'package:prog_1155_midterm/providers/sorting_provider.dart';
import 'package:prog_1155_midterm/services/priority_ordering.dart';
import 'package:prog_1155_midterm/services/map_view.dart';

// A screen showing the current data of the task, most importantly shows a read-only map of the location.
class TaskDetailScreen extends ConsumerWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  // Confirmation prompt when deleting
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final sortOption = ref.read(sortOptionProvider);
      await ref.read(taskListProvider.notifier).deleteTask(
        task.id!,
        sortBy: sortOption.name,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Task Name:', style: Theme.of(context).textTheme.titleMedium),
            Text(task.name, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text('Due Date:', style: Theme.of(context).textTheme.titleMedium),
            Text(task.dueDate, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text('Priority:', style: Theme.of(context).textTheme.titleMedium),
            Text(getPriorityLabel(task.priority), style: Theme.of(context).textTheme.bodyLarge),
            if (task.locationName != null && task.locationName!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Location:', style: Theme.of(context).textTheme.titleMedium),
              Text(task.locationName!, style: Theme.of(context).textTheme.bodyLarge),
            ],
            if (task.latitude != null && task.longitude != null) ...[
              const SizedBox(height: 16),
              Text('Location Preview:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              MapView(
                latitude: task.latitude!,
                longitude: task.longitude!,
              ),
            ],
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Delete Task'),
                onPressed: () => _confirmDelete(context, ref),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
