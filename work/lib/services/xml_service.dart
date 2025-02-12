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
    
    builder.element('registData', nest: () {
      // All data in main group
      builder.element('mainGroup', nest: () {
        // Selections
        builder.element('selections', nest: () {
          builder.element('dropdown1', nest: () {
            builder.element('value', nest: dropdown1Value ?? '');
          });
          builder.element('dropdown2', nest: () {
            builder.element('value', nest: dropdown2Value ?? '');
          });
        });

        // Tasks
        builder.element('tasks', nest: () {
          for (var task in tasks) {
            builder.element('task', nest: () {
              builder.element('title', nest: task['title']);
              builder.element('description', nest: task['description']);
              builder.element('status', nest: task['status']);
              
              // Add related subtasks within each task
              builder.element('subtasks', nest: () {
                final taskSubtasks = subtasks.where(
                  (subtask) => subtask['parentTaskId'] == task['id']
                ).toList();
                
                for (var subtask in taskSubtasks) {
                  builder.element('subtask', nest: () {
                    builder.element('title', nest: subtask['title']);
                    builder.element('status', nest: subtask['status']);
                  });
                }
              });
            });
          }
        });
      });
    });

    final xmlDoc = builder.buildDocument();
    final prettyXml = xmlDoc.toXmlString(pretty: true, indent: '  ');
    await File(registPath).writeAsString(prettyXml);
  }
}
