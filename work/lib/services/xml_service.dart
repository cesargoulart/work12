import 'dart:io';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as path;
import '../models/task_model.dart';
import '../models/subtask_model.dart';
import '../models/project_model.dart';

class XmlService {
  static const String registPath = 'C:/Users/cesar/Documents/assets/regist.xml';
  static const String projectsPath = 'C:/Users/cesar/Documents/assets/projects.xml';

  static Future<String?> loadTextContent(String? dropdown1Value, String? dropdown2Value) async {
    try {
      final file = File(registPath);
      if (!await file.exists()) return null;

      final xmlString = await file.readAsString();
      final document = XmlDocument.parse(xmlString);

      // Find matching mainGroup
      for (var mainGroup in document.findAllElements('mainGroup')) {
        final selections = mainGroup.findElements('selections').firstOrNull;
        if (selections == null) continue;

        final savedDropdown1 = selections.findElements('dropdown1').firstOrNull?.findElements('value').firstOrNull?.text;
        final savedDropdown2 = selections.findElements('dropdown2').firstOrNull?.findElements('value').firstOrNull?.text;

        if (savedDropdown1 == dropdown1Value && savedDropdown2 == dropdown2Value) {
          final textContent = mainGroup.findElements('textContent').firstOrNull;
          return textContent?.text;
        }
      }
      return null;
    } catch (e) {
      print('Error loading text content from regist.xml: $e');
      return null;
    }
  }

  static Future<XmlDocument> loadXmlDocument(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }
    final xmlString = await file.readAsString();
    return XmlDocument.parse(xmlString);
  }

  static Future<Project?> loadProjectByDescription(String description) async {
    try {
      final document = await loadXmlDocument(projectsPath);
      final projectElement = document.findAllElements('project').firstWhere(
        (element) => element.findElements('description').single.text == description,
        orElse: () => XmlElement(XmlName('empty')),
      );

      if (projectElement.name.local != 'empty') {
        final checkboxes = projectElement.findElements('checkboxes').expand((element) {
          return element.findElements('checkbox').map((checkboxElement) {
            final label = checkboxElement.findElements('label').single.text;
            final value = checkboxElement.findElements('value').single.text == 'true';
            return CheckboxModel(label: label, value: value);
          });
        }).toList();

        return Project(description: description, checkboxes: checkboxes);
      }
    } catch (e) {
      print('Error loading project by description: $e');
    }
    return null;
  }

  static Future<List<String>> loadProjectDescriptions() async {
    try {
      final file = File(projectsPath);
      if (!await file.exists()) return [];

      final xmlString = await file.readAsString();
      final document = XmlDocument.parse(xmlString);

      final descriptions = document.findAllElements('description')
          .map((e) => e.text)
          .where((desc) => desc.isNotEmpty)
          .toList();
      return descriptions.reversed.toList();
    } catch (e) {
      print('Error loading descriptions from projects.xml: $e');
      return [];
    }
  }

  static Future<List<Task>> loadTasksFromRegist(String? dropdown1Value, String? dropdown2Value) async {
    try {
      final file = File(registPath);
      if (!await file.exists()) return [];

      final xmlString = await file.readAsString();
      final document = XmlDocument.parse(xmlString);

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

            final hasSubtasks = subtasks.isNotEmpty;

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
        var tasksElement = existingMainGroup.findElements('tasks').firstOrNull;
        if (tasksElement == null) {
          tasksElement = XmlElement(XmlName('tasks'));
          existingMainGroup.children.add(tasksElement);
        }
        tasksElement.children.clear();

        if (tasks.isNotEmpty) {
          tasksElement.children.add(XmlText('\n      '));
          for (var task in tasks) {
            final taskElement = XmlElement(XmlName('task'))
              ..children.addAll([
                XmlText('\n        '),
                XmlElement(XmlName('title'))..children.add(XmlText(task['title'])),
                XmlText('\n        '),
                XmlElement(XmlName('description'))..children.add(XmlText(task['description'])),
                XmlText('\n        '),
                XmlElement(XmlName('status'))..children.add(XmlText(task['status'])),
                XmlText('\n        '),
              ]);

            final subtasksElement = XmlElement(XmlName('subtasks'));
            final taskSubtasks = subtasks.where(
              (subtask) => subtask['parentTaskId'] == task['id']
            ).toList();

            if (taskSubtasks.isNotEmpty) {
              subtasksElement.children.add(XmlText('\n          '));
              for (var subtask in taskSubtasks) {
                subtasksElement.children.addAll([
                  XmlElement(XmlName('subtask'))
                    ..children.addAll([
                      XmlText('\n            '),
                      XmlElement(XmlName('title'))..children.add(XmlText(subtask['title'])),
                      XmlText('\n            '),
                      XmlElement(XmlName('status'))..children.add(XmlText(subtask['status'])),
                      XmlText('\n          '),
                    ]),
                ]);
              }
            }

            taskElement.children.add(subtasksElement);
            taskElement.children.add(XmlText('\n      '));
            tasksElement.children.add(taskElement);
          }
          tasksElement.children.add(XmlText('\n    '));
        }
      } else {
        final newMainGroup = XmlElement(XmlName('mainGroup'))
          ..children.addAll([
            XmlText('\n    '),
            XmlElement(XmlName('selections'))
              ..children.addAll([
                XmlText('\n      '),
                XmlElement(XmlName('dropdown1'))
                  ..children.add(
                    XmlElement(XmlName('value'))
                      ..children.add(XmlText(dropdown1Value ?? '')),
                  ),
                XmlText('\n      '),
                XmlElement(XmlName('dropdown2'))
                  ..children.add(
                    XmlElement(XmlName('value'))
                      ..children.add(XmlText(dropdown2Value ?? '')),
                  ),
                XmlText('\n    '),
              ]),
            XmlText('\n    '),
          ]);

        final tasksElement = XmlElement(XmlName('tasks'));
        if (tasks.isNotEmpty) {
          tasksElement.children.add(XmlText('\n      '));
          for (var task in tasks) {
            final taskElement = XmlElement(XmlName('task'))
              ..children.addAll([
                XmlText('\n        '),
                XmlElement(XmlName('title'))..children.add(XmlText(task['title'])),
                XmlText('\n        '),
                XmlElement(XmlName('description'))..children.add(XmlText(task['description'])),
                XmlText('\n        '),
                XmlElement(XmlName('status'))..children.add(XmlText(task['status'])),
                XmlText('\n        '),
              ]);

            final subtasksElement = XmlElement(XmlName('subtasks'));
            final taskSubtasks = subtasks.where(
              (subtask) => subtask['parentTaskId'] == task['id']
            ).toList();

            if (taskSubtasks.isNotEmpty) {
              subtasksElement.children.add(XmlText('\n          '));
              for (var subtask in taskSubtasks) {
                subtasksElement.children.addAll([
                  XmlElement(XmlName('subtask'))
                    ..children.addAll([
                      XmlText('\n            '),
                      XmlElement(XmlName('title'))..children.add(XmlText(subtask['title'])),
                      XmlText('\n            '),
                      XmlElement(XmlName('status'))..children.add(XmlText(subtask['status'])),
                      XmlText('\n          '),
                    ]),
                ]);
              }
            }

            taskElement.children.add(subtasksElement);
            taskElement.children.add(XmlText('\n      '));
            tasksElement.children.add(taskElement);
          }
          tasksElement.children.add(XmlText('\n    '));
        }

        newMainGroup.children.add(tasksElement);
        newMainGroup.children.add(XmlText('\n  '));

        document.rootElement.children.add(XmlText('\n  '));
        document.rootElement.children.add(newMainGroup);
      }

      document.rootElement.children.add(XmlText('\n'));
      
      final prettyXml = document.toXmlString(pretty: true, indent: '  ');
      await File(registPath).writeAsString(prettyXml);
    } catch (e) {
      print('Error saving to regist.xml: $e');
      rethrow;
    }
  }
}
