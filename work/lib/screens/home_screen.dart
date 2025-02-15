import 'dart:io';
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../widgets/animated_search_bar.dart';
import '../widgets/save_to_xml_button.dart';
import '../services/xml_service.dart';
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
  }

  Future<void> _loadTasks() async {
    final tasks = await XmlService.loadTasksFromRegist(_firstDropdownValue, _secondDropdownValue);
    final textContent = await XmlService.loadTextContent(_firstDropdownValue, _secondDropdownValue);
    
    setState(() {
      _tasks = tasks;
    });
    
    HandlePurpleButtonPress.setText(textContent);
  }

  String _safeString(String? value) => value ?? '';

  Future<void> _loadTasksFromXML() async {
    try {
      final file = File('C:/Users/cesar/Documents/assets/tasks.xml');
      if (!await file.exists()) return;

      final xmlString = await file.readAsString();
      final document = XmlDocument.parse(xmlString);

      // Check if current dropdown selections match saved selections
      final selectionsElement = document.findAllElements('selections').firstOrNull;
      final savedFirstDropdown = selectionsElement?.findElements('firstDropdown').firstOrNull?.text;
      final savedSecondDropdown = selectionsElement?.findElements('secondDropdown').firstOrNull?.text;

      // If they don't match, clear tasks
      if (_firstDropdownValue != savedFirstDropdown || _secondDropdownValue != savedSecondDropdown) {
        setState(() {
          _tasks = [];
        });
        return;
      }

      final taskListElement = document.findAllElements('taskList').firstOrNull;
      if (taskListElement == null) return;

      final tasks = taskListElement.findElements('task').map((taskElement) {
        final subtasksElement = taskElement.findElements('subtasks').firstOrNull;
        final subtasks = subtasksElement?.findElements('subtask').map((subtaskElement) {
          return Subtask(
            id: subtaskElement.findElements('id').first.text,
            taskId: taskElement.findElements('id').first.text,
            title: subtaskElement.findElements('title').first.text,
            createdAt: DateTime.parse(subtaskElement.findElements('createdAt').first.text),
            isCompleted: subtaskElement.findElements('isCompleted').first.text.toLowerCase() == 'true',
          );
        }).toList() ?? [];

        return Task(
          id: taskElement.findElements('id').first.text,
          title: taskElement.findElements('title').first.text,
          description: taskElement.findElements('description').first.text,
          createdAt: DateTime.parse(taskElement.findElements('createdAt').first.text),
          isCompleted: taskElement.findElements('isCompleted').first.text.toLowerCase() == 'true',
          subtasks: subtasks,
        );
      }).toList();

      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      print('Error loading tasks: $e');
    }
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

  Future<void> _handlePurpleButtonPressed() async {
    try {
      final tasksFile = File('C:/Users/cesar/Documents/assets/tasks.xml');
      XmlDocument existingDocument;
      
      if (await tasksFile.exists()) {
        final xmlString = await tasksFile.readAsString();
        existingDocument = XmlDocument.parse(xmlString);
      } else {
        existingDocument = XmlDocument([
          XmlProcessing('xml', 'version="1.0" encoding="UTF-8"'),
          XmlElement(XmlName('tasks'))
        ]);
      }

      // Add new selections
      final tasksRoot = existingDocument.findAllElements('tasks').first;
      final selectionsElement = XmlElement(XmlName('selections'));

      // Create non-null strings for values
      final String firstValue = _safeString(_firstDropdownValue);
      final String secondValue = _safeString(_secondDropdownValue);

      selectionsElement.children.addAll([
        XmlElement(XmlName('firstDropdown'))..children.add(XmlText(firstValue)),
        XmlElement(XmlName('secondDropdown'))..children.add(XmlText(secondValue)),
      ]);
      
      // Add new tasks
      final taskListElement = XmlElement(XmlName('taskList'));
      for (var task in _tasks) {
        final taskElement = XmlElement(XmlName('task'))
          ..children.addAll([
            XmlElement(XmlName('id'))..children.add(XmlText(task.id)),
            XmlElement(XmlName('title'))..children.add(XmlText(task.title)),
            XmlElement(XmlName('description'))..children.add(XmlText(_safeString(task.description))),
            XmlElement(XmlName('createdAt'))..children.add(XmlText(task.createdAt.toIso8601String())),
            XmlElement(XmlName('isCompleted'))..children.add(XmlText(task.isCompleted.toString())),
          ]);

        final subtasksElement = XmlElement(XmlName('subtasks'));
        for (var subtask in task.subtasks) {
          final subtaskElement = XmlElement(XmlName('subtask'))
            ..children.addAll([
              XmlElement(XmlName('id'))..children.add(XmlText(subtask.id)),
              XmlElement(XmlName('title'))..children.add(XmlText(subtask.title)),
              XmlElement(XmlName('createdAt'))..children.add(XmlText(subtask.createdAt.toIso8601String())),
              XmlElement(XmlName('isCompleted'))..children.add(XmlText(subtask.isCompleted.toString())),
            ]);
          subtasksElement.children.add(subtaskElement);
        }
        taskElement.children.add(subtasksElement);
        taskListElement.children.add(taskElement);
      }

      // Add proper indentation
      tasksRoot.children.addAll([
        XmlText('\n  '),
        selectionsElement,
        XmlText('\n  '),
        taskListElement,
        XmlText('\n')
      ]);

      await tasksFile.writeAsString(existingDocument.toXmlString(pretty: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tasks saved successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving tasks: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    try {
      bool hasCheckedBox = _checkboxValues.values.any((value) => value);
      if (!hasCheckedBox && _textController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one option or enter text'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final directory = Directory(r'C:\Users\cesar\Documents\assets');
      final file = File(r'C:\Users\cesar\Documents\assets\projects.xml');

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      XmlDocument document;
      if (await file.exists()) {
        final xmlString = await file.readAsString();
        document = XmlDocument.parse(xmlString);
      } else {
        document = XmlDocument([
          XmlProcessing('xml', 'version="1.0" encoding="UTF-8"'),
          XmlElement(XmlName('projects'))
        ]);
      }
      
      final text = _textController.text.trim();
      final projectsRoot = document.findAllElements('projects');
      if (projectsRoot.isEmpty) {
        document.root.children.add(XmlElement(XmlName('projects')));
      }
      final projects = document.findAllElements('project');
      XmlElement? projectToUpdate;
      
      for (var project in projects) {
        final descriptionElement = project.findElements('description').firstOrNull;
        if (descriptionElement != null && descriptionElement.text == text) {
          projectToUpdate = project;
          break;
        }
      }

      if (projectToUpdate == null) {
        final projectsRootElement = document.findAllElements('projects').first;
        projectToUpdate = XmlElement(XmlName('project'));
        
        projectsRootElement.children.add(XmlText('\n  '));
        projectsRootElement.children.add(projectToUpdate);
        projectsRootElement.children.add(XmlText('\n'));
        
        projectToUpdate.children.add(XmlText('    '));
        projectToUpdate.children.add(XmlElement(XmlName('description'))..children.add(XmlText(text)));
        projectToUpdate.children.add(XmlText('\n  '));
      }

      // Remove existing checkboxes element
      projectToUpdate.findElements('checkboxes').forEach((element) => element.remove());

      // Add new checkboxes element
      projectToUpdate.children.add(XmlText('    '));
      final checkboxesElement = XmlElement(XmlName('checkboxes'));
      projectToUpdate.children.add(checkboxesElement);
      projectToUpdate.children.add(XmlText('\n  '));
      
      _checkboxValues.forEach((label, value) {
        checkboxesElement.children.add(XmlText('\n      '));
        final labelElement = XmlElement(XmlName('label'))..children.add(XmlText(label));
        final valueElement = XmlElement(XmlName('value'))..children.add(XmlText(value.toString()));
        final checkboxElement = XmlElement(XmlName('checkbox'))
          ..children.add(XmlText('\n        '))
          ..children.add(labelElement)
          ..children.add(XmlText('\n        '))
          ..children.add(valueElement)
          ..children.add(XmlText('\n      '));
        checkboxesElement.children.add(checkboxElement);
      });

      await file.writeAsString(document.toXmlString(pretty: true));
      
      _textController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully saved to projects.xml'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving file: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      SnackBar(
        content: const Text('Help section coming soon!'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          backgroundColor: Colors.green,
          onPressed: () {},
        ),
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
        final subtaskIndex = _tasks[taskIndex].subtasks.indexWhere((subtask) => subtask.id == subtaskId);
        if (subtaskIndex != -1) {
          _tasks[taskIndex].subtasks[subtaskIndex].isCompleted =
              !_tasks[taskIndex].subtasks[subtaskIndex].isCompleted;
        }
      }
    });
  }

  // Called whenever text in the AnimatedSearchBar changes
  void _handleTextChanged(String query) {
    // For now, we do nothing. You can implement search here if needed.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Top row with search bar and purple button
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

                      const SizedBox(height: 16),
                      // Two dropdowns plus add button
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

                      // AnimatedTaskList
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
            Row(
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
          ],
        ),
      ),
    );
  }
}
