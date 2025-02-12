import 'dart:io';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as path;

class XmlService {
  static const String registPath = 'C:/Users/cesar/Documents/assets/regist.xml';

  static Future<void> saveToXml({
    required String? dropdown1Value,
    required String? dropdown2Value,
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> subtasks,
  }) async {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    
    builder.element('data', nest: () {
      // Add dropdowns
      builder.element('dropdowns', nest: () {
        builder.element('dropdown1', nest: dropdown1Value ?? '');
        builder.element('dropdown2', nest: dropdown2Value ?? '');
      });

      // Add tasks
      builder.element('tasks', nest: () {
        for (var task in tasks) {
          builder.element('task', nest: () {
            builder.element('title', nest: task['title']);
            builder.element('description', nest: task['description'] ?? '');
            builder.element('status', nest: task['status'] ?? '');
          });
        }
      });

      // Add subtasks
      builder.element('subtasks', nest: () {
        for (var subtask in subtasks) {
          builder.element('subtask', nest: () {
            builder.element('title', nest: subtask['title']);
            builder.element('parentTaskId', nest: subtask['parentTaskId'].toString());
            builder.element('status', nest: subtask['status'] ?? '');
          });
        }
      });
    });

    final xmlString = builder.buildDocument().toString();
    await File(registPath).writeAsString(xmlString);
  }
}
