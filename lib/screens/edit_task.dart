import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prog_1155_midterm/models/task.dart';
import 'package:prog_1155_midterm/providers/task_list_provider.dart';
import 'package:prog_1155_midterm/providers/sorting_provider.dart';
import 'package:prog_1155_midterm/services/priority_ordering.dart';
import 'package:prog_1155_midterm/services/map_select.dart';


// After a tasks has been previously been added, allow it to be edited.
// Loads in the current data to be changed. Otherwise same as "add_task"
class EditTaskScreen extends ConsumerStatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  int? _selectedPriority;
  DateTime? _selectedDate;

  String? _locationName;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.name);
    _selectedPriority = widget.task.priority;
    _selectedDate = DateTime.tryParse(widget.task.dueDate);
    _locationName = widget.task.locationName;
    _latitude = widget.task.latitude;
    _longitude = widget.task.longitude;
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectLocation() async {
    LatLng? initialPosition;
    if (_latitude != null && _longitude != null) {
      initialPosition = LatLng(_latitude!, _longitude!);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapSelect(initialLatLng: initialPosition)),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _locationName = result['name'];
        _latitude = result['lat'];
        _longitude = result['lng'];
      });
    }
  }


  Future<void> _updateTask() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedPriority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final updatedTask = Task(
      id: widget.task.id,
      name: _nameController.text.trim(),
      dueDate: _selectedDate!.toIso8601String().split('T')[0],
      priority: _selectedPriority!,
      locationName: _locationName,
      latitude: _latitude,
      longitude: _longitude,
    );

    try {
      final sortOption = ref.read(sortOptionProvider);
      await ref.read(taskListProvider.notifier).updateTask(
        updatedTask,
        sortBy: sortOption.name == 'priority' ? 'priority' : 'dueDate',
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
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
                          ? 'No date selected'
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
                onPressed: _updateTask,
                child: const Text('Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
