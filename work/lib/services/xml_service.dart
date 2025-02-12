import 'dart:io';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as path;
import '../models/task_model.dart';
import '../models/subtask_model.dart';

class XmlService {
  static const String registPath = 'C:/Users/cesar/Documents/assets/regist.xml';

  static Future<List<Task>> loadTasksFromRegist(String? dropdown1Value, String? dropdown2Value) async {
    try {
      final file = File(registPath);
      if (!await file.exists()) return [];

      final xmlString = await file.readAsString();
      final document = XmlDocument.parse(xmlString);

      // Load tasks from the mainGroup that matches the current dropdown values
      for (var mainGroup in document.findAllElements('mainGroup')) {
        final selections = mainGroup.findElements('selections').firstOrNull;
        if (selections == null) continue;

        final savedDropdown1 = selections.findElements('dropdown1').firstOrNull?.findElements('value').firstOrNull?.text;
        final savedDropdown2 = selections.findElements('dropdown2').firstOrNull?.findElements('value').firstOrNull?.text;

        if (savedDropdown1 == dropdown1Value && savedDropdown2 == dropdown2Value) {
          final tasksElement = mainGroup.findElements('tasks').firstOrNull;
          if (tasksElement == null) continue;

          return tasksElement.findElements('task').map((taskElement) {
            final id = DateTime.now().toString();
            final title = taskElement.findElements('title').firstOrNull?.text ?? '';
            final description = taskElement.findElements('description').firstOrNull?.text ?? '';
            final status = taskElement.findElements('status').firstOrNull?.text?.toLowerCase() == 'true';

            final subtasksElement = taskElement.findElements('subtasks').firstOrNull;
            final subtasks = subtasksElement?.findElements('subtask').map((subtaskElement) {
              return Subtask(
                id: DateTime.now().toString(),
                taskId: id,
                title: subtaskElement.findElements('title').firstOrNull?.text ?? '',
                createdAt: DateTime.now(),
                isCompleted: subtaskElement.findElements('status').firstOrNull?.text?.toLowerCase() == 'true',
              );
            }).toList() ?? [];

            final hasSubtasks = !subtasks.isEmpty;

            return Task(
              id: id,
              title: title,
              description: description,
              createdAt: DateTime.now(),
              isCompleted: status,
              subtasks: subtasks,
              isExpanded: hasSubtasks,
            );
          }).toList();
        }
      }

      return [];
    } catch (e) {
      print('Error loading tasks from regist.xml: $e');
      return [];
    }
  }

  static Future<void> saveToXml({
    required String? dropdown1Value,
    required String? dropdown2Value,
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> subtasks,
  }) async {
    try {
      XmlDocument document;
      
      // Load or create document
      if (await File(registPath).exists()) {
        final xmlString = await File(registPath).readAsString();
        try {
          document = XmlDocument.parse(xmlString);
        } catch (e) {
          document = XmlDocument([
            XmlProcessing('xml', 'version="1.0" encoding="UTF-8"'),
            XmlElement(XmlName('registData'))
          ]);
        }
      } else {
        document = XmlDocument([
          XmlProcessing('xml', 'version="1.0" encoding="UTF-8"'),
          XmlElement(XmlName('registData'))
        ]);
      }

      // Find existing mainGroup with matching selections
      XmlElement? existingMainGroup;
      for (var mainGroup in document.findAllElements('mainGroup')) {
        final selections = mainGroup.findElements('selections').firstOrNull;
        if (selections != null) {
          final savedDropdown1 = selections.findElements('dropdown1').firstOrNull?.findElements('value').firstOrNull?.text;
          final savedDropdown2 = selections.findElements('dropdown2').firstOrNull?.findElements('value').firstOrNull?.text;

          if (savedDropdown1 == dropdown1Value && savedDropdown2 == dropdown2Value) {
            existingMainGroup = mainGroup;
            break;
          }
        }
      }

      if (existingMainGroup != null) {
        // Update existing mainGroup
        var tasksElement = existingMainGroup.findElements('tasks').firstOrNull;
        if (tasksElement == null) {
          tasksElement = XmlElement(XmlName('tasks'));
          existingMainGroup.children.add(tasksElement);
        }
        tasksElement.children.clear();

        if (tasks.isNotEmpty) {
          tasksElement.children.add(XmlText('\n      ')); // Initial indentation
          
          for (var task in tasks) {
            final taskElement = XmlElement(XmlName('task'))
              ..children.addAll([
                XmlText('\n        '), // Indentation
                XmlElement(XmlName('title'))..children.add(XmlText(task['title'])),
                XmlText('\n        '), // Indentation
                XmlElement(XmlName('description'))..children.add(XmlText(task['description'])),
                XmlText('\n        '), // Indentation
                XmlElement(XmlName('status'))..children.add(XmlText(task['status'])),
                XmlText('\n        '), // Indentation
              ]);

            // Add subtasks
            final subtasksElement = XmlElement(XmlName('subtasks'));
            final taskSubtasks = subtasks.where(
              (subtask) => subtask['parentTaskId'] == task['id']
            ).toList();

            if (taskSubtasks.isNotEmpty) {
              subtasksElement.children.add(XmlText('\n          ')); // Indentation
              for (var subtask in taskSubtasks) {
                subtasksElement.children.addAll([
                  XmlElement(XmlName('subtask'))
                    ..children.addAll([
                      XmlText('\n            '), // Indentation
                      XmlElement(XmlName('title'))..children.add(XmlText(subtask['title'])),
                      XmlText('\n            '), // Indentation
                      XmlElement(XmlName('status'))..children.add(XmlText(subtask['status'])),
                      XmlText('\n          '), // Indentation
                    ]),
                ]);
              }
            }

            taskElement.children.add(subtasksElement);
            taskElement.children.add(XmlText('\n      ')); // Indentation
            tasksElement.children.add(taskElement);
          }
          tasksElement.children.add(XmlText('\n    ')); // Final indentation
        }
      } else {
        // Create new mainGroup
        final newMainGroup = XmlElement(XmlName('mainGroup'));
        newMainGroup.children.addAll([
          XmlText('\n    '), // Indentation
          XmlElement(XmlName('selections'))
            ..children.addAll([
              XmlText('\n      '), // Indentation
              XmlElement(XmlName('dropdown1'))
                ..children.add(
                  XmlElement(XmlName('value'))
                    ..children.add(XmlText(dropdown1Value ?? '')),
                ),
              XmlText('\n      '), // Indentation
              XmlElement(XmlName('dropdown2'))
                ..children.add(
                  XmlElement(XmlName('value'))
                    ..children.add(XmlText(dropdown2Value ?? '')),
                ),
              XmlText('\n    '), // Indentation
            ]),
          XmlText('\n    '), // Indentation
        ]);

        // Add tasks element
        final tasksElement = XmlElement(XmlName('tasks'));
        if (tasks.isNotEmpty) {
          tasksElement.children.add(XmlText('\n      ')); // Initial indentation
          
          for (var task in tasks) {
            final taskElement = XmlElement(XmlName('task'))
              ..children.addAll([
                XmlText('\n        '), // Indentation
                XmlElement(XmlName('title'))..children.add(XmlText(task['title'])),
                XmlText('\n        '), // Indentation
                XmlElement(XmlName('description'))..children.add(XmlText(task['description'])),
                XmlText('\n        '), // Indentation
                XmlElement(XmlName('status'))..children.add(XmlText(task['status'])),
                XmlText('\n        '), // Indentation
              ]);

            // Add subtasks
            final subtasksElement = XmlElement(XmlName('subtasks'));
            final taskSubtasks = subtasks.where(
              (subtask) => subtask['parentTaskId'] == task['id']
            ).toList();

            if (taskSubtasks.isNotEmpty) {
              subtasksElement.children.add(XmlText('\n          ')); // Indentation
              for (var subtask in taskSubtasks) {
                subtasksElement.children.addAll([
                  XmlElement(XmlName('subtask'))
                    ..children.addAll([
                      XmlText('\n            '), // Indentation
                      XmlElement(XmlName('title'))..children.add(XmlText(subtask['title'])),
                      XmlText('\n            '), // Indentation
                      XmlElement(XmlName('status'))..children.add(XmlText(subtask['status'])),
                      XmlText('\n          '), // Indentation
                    ]),
                ]);
              }
            }

            taskElement.children.add(subtasksElement);
            taskElement.children.add(XmlText('\n      ')); // Indentation
            tasksElement.children.add(taskElement);
          }
          tasksElement.children.add(XmlText('\n    ')); // Final indentation
        }

        newMainGroup.children.add(tasksElement);
        newMainGroup.children.add(XmlText('\n  ')); // Final indentation

        // Add the new mainGroup to the document
        document.rootElement.children.add(XmlText('\n  ')); // Indentation
        document.rootElement.children.add(newMainGroup);
      }

      document.rootElement.children.add(XmlText('\n')); // Final newline

      // Save with proper formatting
      final prettyXml = document.toXmlString(pretty: true, indent: '  ');
      await File(registPath).writeAsString(prettyXml);
    } catch (e) {
      print('Error saving to regist.xml: $e');
      rethrow;
    }
  }
}
