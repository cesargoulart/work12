import 'package:flutter/material.dart';
import '../widgets/animated_search_bar.dart';
import '../widgets/animated_checkbox_group.dart';
import '../widgets/animated_dropdown.dart';
import '../widgets/animated_add_button.dart';
import '../widgets/animated_task_dialog.dart';
import '../widgets/animated_task_list.dart';
import '../models/task_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _firstDropdownValue;
  String? _secondDropdownValue;
  List<Task> _tasks = [];
  
  final List<String> _firstDropdownItems = ['Option 1', 'Option 2', 'Option 3'];
  final List<String> _secondDropdownItems = ['Choice A', 'Choice B', 'Choice C'];

  final Map<String, bool> _checkboxValues = {
    'MR': false,
    'COM': false,
    'DEV1': false,
    'DEV2': false,
    'REC1': false,
    'REC2': false,
  };

  void _handleSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved successfully!')),
    );
  }

  void _handleHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help section coming soon!')),
    );
  }

  void _handleAddPressed() {
    showDialog(
      context: context,
      builder: (context) => AnimatedTaskDialog(
        onTaskCreated: (title, description) {
          setState(() {
            _tasks.add(Task(
              id: DateTime.now().toString(),
              title: title,
              description: description,
              createdAt: DateTime.now(),
            ));
          });
        },
      ),
    );
  }

  void _handleTaskToggle(String taskId) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      }
    });
  }

  void _handleTaskDelete(String taskId) {
    setState(() {
      _tasks.removeWhere((task) => task.id == taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                AnimatedSearchBar(
                  controller: _textController,
                  onSave: _handleSave,
                  onHelpPressed: _handleHelp,
                ),
                AnimatedCheckboxGroup(
                  labels: const ['MR', 'COM', 'DEV1', 'DEV2', 'REC1', 'REC2'],
                  values: _checkboxValues,
                  onChanged: (label, value) {
                    setState(() {
                      _checkboxValues[label] = value;
                    });
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          AnimatedDropdown(
                            hint: 'Select first option',
                            items: _firstDropdownItems,
                            value: _firstDropdownValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                _firstDropdownValue = newValue;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedAddButton(
                              onPressed: _handleAddPressed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimatedDropdown(
                        hint: 'Select second option',
                        items: _secondDropdownItems,
                        value: _secondDropdownValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            _secondDropdownValue = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_tasks.isNotEmpty)
                  AnimatedTaskList(
                    tasks: _tasks,
                    onTaskToggle: _handleTaskToggle,
                    onTaskDelete: _handleTaskDelete,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}