import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prog_1155_midterm/providers/task_list_provider.dart';
import 'package:prog_1155_midterm/providers/sorting_provider.dart';
import 'package:prog_1155_midterm/screens/add_task.dart';
import 'package:prog_1155_midterm/screens/edit_task.dart';
import 'package:prog_1155_midterm/screens/task_details.dart';
import 'package:prog_1155_midterm/screens/task_advice.dart';
import 'package:prog_1155_midterm/services/priority_ordering.dart';

/*
Shows a list of the current tasks
Allows adding new tasks by using the FAB
Tasks can be swiped to be deleted
Using the menu top-right the tasks can be ordered based on priority or due date
Allows navigation to AI-helper
Includes tabs for public and private tasks
*/
class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final sortOption = ref.watch(sortOptionProvider);
    final publicTasks = ref.watch(publicTaskListProvider);
    final privateTasks = ref.watch(privateTaskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tips_and_updates),
            tooltip: 'Task Advice',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskAdvice()),
              );
            },
          ),
          PopupMenuButton<SortOption>(
            onSelected: (SortOption selected) async {
              await ref.read(sortOptionProvider.notifier).setSortOption(selected);
              await ref.read(publicTaskListProvider.notifier).loadTasks(
                sortBy: selected == SortOption.priority ? 'priority' : 'dueDate',
              );
              await ref.read(privateTaskListProvider.notifier).loadTasks(
                sortBy: selected == SortOption.priority ? 'priority' : 'dueDate',
              );
            },
            itemBuilder: (context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem(
                value: SortOption.dueDate,
                child: Text('Sort by Due Date'),
              ),
              const PopupMenuItem(
                value: SortOption.priority,
                child: Text('Sort by Priority'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Public'),
            Tab(text: 'Private'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(publicTasks, isPrivate: false),
          _buildTaskList(privateTasks, isPrivate: true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(List taskList, {required bool isPrivate}) {
    final sortOption = ref.watch(sortOptionProvider);
    final notifier = isPrivate
        ? ref.read(privateTaskListProvider.notifier)
        : ref.read(publicTaskListProvider.notifier);

    return ListView.separated(
      itemCount: taskList.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final task = taskList[index];

        return Dismissible(
          key: Key('${task.id}-${isPrivate ? 'private' : 'public'}'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) async {
            if (isPrivate) {
              await (notifier as PrivateTaskListNotifier).deleteTask(
                task.id.toString(), // Encrypted tasks use String IDs
                sortBy: sortOption.name,
              );
            } else {
              await (notifier as PublicTaskListNotifier).deleteTask(
                task.id!,
                sortBy: sortOption.name,
              );
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task deleted')),
            );
          },
          child: ListTile(
            title: Text(task.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Due: ${task.dueDate} | Priority: ${getPriorityLabel(task.priority)}'),
                if (task.locationName != null && task.locationName!.isNotEmpty)
                  Text('Location: ${task.locationName}', style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
