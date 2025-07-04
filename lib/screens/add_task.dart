import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prog_1155_midterm/models/task.dart';
import 'package:prog_1155_midterm/providers/task_list_provider.dart';
import 'package:prog_1155_midterm/providers/sorting_provider.dart';
import 'package:prog_1155_midterm/services/priority_ordering.dart';
import 'package:prog_1155_midterm/services/map_select.dart';

// Screen shown after clicking the FAB, to add a new tasks
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

  String? _locationName;
  double? _latitude;
  double? _longitude;

  // Select a date user the date picker.
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

  // Allow the user to select a location
  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapSelect()),
    );

    // Save the chosen location to the task
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _locationName = result['name'];
        _latitude = result['lat'];
        _longitude = result['lng'];
      });
    }
  }

  // After validating, save to db
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedPriority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final newTask = Task(
      name: _nameController.text.trim(),
      dueDate: _selectedDate!.toIso8601String().split('T')[0],
      priority: _selectedPriority!,
      locationName: _locationName,
      latitude: _latitude,
      longitude: _longitude,
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
                          : 'Due Date: ${_selectedDate!.toIso8601String().split('T')[0]}',
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
              ElevatedButton.icon(
                onPressed: _selectLocation,
                icon: const Icon(Icons.map),
                label: const Text('Select Task Location'),
              ),
              if (_locationName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Selected Location: $_locationName',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
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
