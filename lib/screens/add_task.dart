import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prog_1155_midterm/models/task.dart';
import 'package:prog_1155_midterm/providers/task_list_provider.dart';
import 'package:prog_1155_midterm/providers/sorting_provider.dart';
import 'package:prog_1155_midterm/services/priority_ordering.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int? _selectedPriority;
  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedPriority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final newTask = Task(
      name: _nameController.text.trim(),
      dueDate: _selectedDate!.toIso8601String().split('T')[0],
      priority: _selectedPriority!,
    );

    try {
      final sortOption = ref.read(sortOptionProvider);
      await ref.read(taskListProvider.notifier).addTask(
        newTask,
        sortBy: sortOption.name == 'priority' ? 'priority' : 'dueDate',
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Task name is required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No date chosen'
                          : 'Due Date: ${_selectedDate!.toLocal().toIso8601String().split('T')[0]}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectDate,
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: [1, 2, 3].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(getPriorityLabel(value)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedPriority = value),
                validator: (value) => value == null ? 'Please select a priority' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
