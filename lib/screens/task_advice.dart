import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prog_1155_midterm/models/task.dart';
import 'package:prog_1155_midterm/providers/task_list_provider.dart';
import 'package:prog_1155_midterm/services/openai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Shows the response of OpenAI based on the tasks in the task list.
class TaskAdvice extends ConsumerStatefulWidget {
  const TaskAdvice({super.key});

  @override
  ConsumerState<TaskAdvice> createState() => _TaskAdviceState();
}

class _TaskAdviceState extends ConsumerState<TaskAdvice> {
  String? _response;
  bool _isLoading = true;
  // Set up the openai service
  final OpenAIService _openAIService = OpenAIService();

  @override
  void initState() {
    super.initState();
    _loadTasksAndFetchAdvice();
  }

  Future<void> _loadTasksAndFetchAdvice() async {
    try {
      // Load tasks from the provider
      await ref.read(taskListProvider.notifier).loadTasks();
      final tasks = ref.read(taskListProvider);

      // Generate a readable summary
      final taskSummary = _summarizeTasks(tasks);

      // Call OpenAI
      final result = await _openAIService.getAdviceFromOpenAI(taskSummary);

      setState(() {
        _response = result ?? 'No advice received.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  // Format the tasks for AI understanding
  String _summarizeTasks(List<Task> tasks) {
    if (tasks.isEmpty) return "I have no tasks at the moment.";
    return tasks.map((t) {
      final loc = (t.locationName?.isNotEmpty ?? false) ? " at ${t.locationName}" : "";
      return "- ${t.name}, due ${t.dueDate}, priority ${t.priority}$loc";
    }).join("\n");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Task Guide')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          // Since OpenAI is capable of providing lists using markdown, format it as such.
          child: MarkdownBody(
            data: _response!,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
