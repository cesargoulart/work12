import 'dart:io';
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../widgets/animated_search_bar.dart';
import '../widgets/save_to_xml_button.dart';
import '../services/xml_service.dart';
import '../services/save_handler.dart';
import '../features/handle_green_button_press.dart';
import '../widgets/green_h_button.dart';
import '../widgets/animated_checkbox_group.dart';
import '../widgets/animated_dropdown.dart';
import '../widgets/animated_add_button.dart';
import '../widgets/animated_task_dialog.dart';
import '../widgets/animated_task_list.dart';
import '../widgets/large_text_box.dart';
import '../widgets/purple_button.dart';
import '../models/task_model.dart';
import '../models/subtask_model.dart';
import '../features/handle_purple_button_press.dart';
import '../features/update_checkboxes.dart';
import '../features/handle_description_updates.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  String? _firstDropdownValue;
  String? _secondDropdownValue;
  List<Task> _tasks = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<String> _firstDropdownItems = [];
  List<String> _secondDropdownItems = [];

  final Map<String, bool> _checkboxValues = {
    'MR REC': false,
    'MR PKG': false,
    'COM': false,
    'DEV1': false,
    'DEV2': false,
    'REC1': false,
    'REC2': false,
  };

  @override
  void initState() {
    super.initState();
    _loadDropdownItems();
    _loadLastProject();
    _loadTasks();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
    
    // Initialize checkbox updater
    initCheckboxUpdater((newValues) {
      setState(() {
        _checkboxValues.clear();
        _checkboxValues.addAll(newValues);
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final tasks = await XmlService.loadTasksFromRegist(_firstDropdownValue, _secondDropdownValue);
    final textContent = await XmlService.loadTextContent(_firstDropdownValue, _secondDropdownValue);
    
    setState(() {
      _tasks = tasks;
    });
    
    HandlePurpleButtonPress.setText(textContent);
  }

  void _loadDropdownItems() async {
    try {
      final file = File('C:/Users/cesar/Documents/assets/tasks.xml');
      final xmlString = await file.readAsString();
      final document = XmlDocument.parse(xmlString);

      final dropdown1Element = document.findAllElements('dropdown1').first;
      final dropdown2Element = document.findAllElements('dropdown2').first;

      final items1 = dropdown1Element.findElements('item').map((node) => node.text).toList();
      final items2 = dropdown2Element.findElements('item').map((node) => node.text).toList();

      setState(() {
        _firstDropdownItems = items1;
        _secondDropdownItems = items2;
      });
    } catch (e) {
      setState(() {
        _firstDropdownItems = [];
        _secondDropdownItems = [];
      });
    }
  }

  void _loadLastProject() async {
    try {
      final file = File('C:/Users/cesar/Documents/assets/projects.xml');
      if (!await file.exists()) return;

      final xmlString = await file.readAsString();
      final document = XmlDocument.parse(xmlString);
      
      final projects = document.findAllElements('project').toList();
      if (projects.isEmpty) return;
      
      final lastProject = projects.last;
      final checkboxesElement = lastProject.findElements('checkboxes').firstOrNull;
      if (checkboxesElement == null) return;

      setState(() {
        _checkboxValues.updateAll((key, value) => false);
        
        for (var checkbox in checkboxesElement.findElements('checkbox')) {
          final label = checkbox.findElements('label').firstOrNull?.text;
          final val = checkbox.findElements('value').firstOrNull?.text;
          if (label != null && _checkboxValues.containsKey(label)) {
            _checkboxValues[label] = val?.toLowerCase() == 'true';
          }
        }
      });
    } catch (e) {
      print('Error loading last project: $e');
    }
  }

  Future<void> _handleSave() async {
    // Get the current description from the DescriptionUpdateHandler.
    // If it's "No description", treat it as empty.
    final currentDescription = DescriptionUpdateHandler().getCurrentDescription();
    await SaveHandler.saveToXml(
      checkboxValues: _checkboxValues,
      text: _textController.text.trim(),
      context: context,
      currentDescription: (currentDescription == 'No description') ? '' : currentDescription,
    );
    
    if (mounted) {
      _textController.clear();
    }
  }

  void _handleTaskExpand(String taskId) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex].isExpanded = !_tasks[taskIndex].isExpanded;
      }
    });
  }

  void _handleHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help section coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF424242),
      ),
    );
  }

  void _handleAddPressed() {
    showDialog(
      context: context,
      builder: (context) => AnimatedTaskDialog(
        onTaskCreated: (title, description) {
          setState(() {
            _tasks.add(
              Task(
                id: DateTime.now().toString(),
                title: title,
                description: description,
                createdAt: DateTime.now(),
                isExpanded: false,
              ),
            );
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

  void _handleSubtaskCreated(String taskId, String title) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex].subtasks.add(
          Subtask(
            id: DateTime.now().toString(),
            taskId: taskId,
            title: title,
            createdAt: DateTime.now(),
          ),
        );
        _tasks[taskIndex].isExpanded = true;
      }
    });
  }

  void _handleSubtaskToggle(String taskId, String subtaskId) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final subtaskIndex = _tasks[taskIndex].subtasks.indexWhere(
          (subtask) => subtask.id == subtaskId
        );
        if (subtaskIndex != -1) {
          _tasks[taskIndex].subtasks[subtaskIndex].isCompleted =
              !_tasks[taskIndex].subtasks[subtaskIndex].isCompleted;
        }
      }
    });
  }

  void _handleTextChanged(String query) {
    // For now, we do nothing. You can implement search here if needed.
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        cardColor: const Color(0xFF2D2D2D),
        primaryColor: Colors.deepPurple,
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.deepPurpleAccent,
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Top row with search bar and buttons
                          Row(
                            children: [
                              Expanded(
                                child: AnimatedSearchBar(
                                  controller: _textController,
                                  onSave: _handleSave,
                                  onHelpPressed: _handleHelp,
                                  onChanged: _handleTextChanged,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GreenHButton(
                                onPressed: () => handleGreenButtonPress(context),
                              ),
                              const SizedBox(width: 8),
                              SaveToXmlButton(
                                dropdown1Value: _firstDropdownValue,
                                dropdown2Value: _secondDropdownValue,
                                tasks: _tasks,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Checkboxes
                          AnimatedCheckboxGroup(
                            labels: const [
                              'MR REC',
                              'MR PKG',
                              'COM',
                              'DEV1',
                              'DEV2',
                              'REC1',
                              'REC2'
                            ],
                            values: _checkboxValues,
                            onChanged: (label, value) {
                              setState(() {
                                _checkboxValues[label] = value;
                              });
                            },
                          ),

                          const SizedBox(height: 24),
                          
                          // Dropdowns and add button
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
                                      onChanged: (String? newValue) async {
                                        setState(() {
                                          _firstDropdownValue = newValue;
                                        });
                                        await _loadTasks();
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
                                  onChanged: (String? newValue) async {
                                    setState(() {
                                      _secondDropdownValue = newValue;
                                    });
                                    await _loadTasks();
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Task List
                          if (_tasks.isNotEmpty)
                            AnimatedTaskList(
                              tasks: _tasks,
                              onTaskToggle: _handleTaskToggle,
                              onTaskDelete: _handleTaskDelete,
                              onTaskExpand: _handleTaskExpand,
                              onSubtaskCreated: _handleSubtaskCreated,
                              onSubtaskToggle: _handleSubtaskToggle,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom row with text box and purple button
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LargeTextBox(
                            onTextChanged: HandlePurpleButtonPress.updateText,
                            controller: HandlePurpleButtonPress.textController,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: PurpleButton(
                          onPressed: HandlePurpleButtonPress.handlePress,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
