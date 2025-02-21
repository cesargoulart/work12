import 'package:flutter/material.dart';
import '../services/xml_service.dart';
import 'purple_button.dart';
import '../models/task_model.dart';

class SaveToXmlButton extends StatelessWidget {
  final String? dropdown1Value;
  final String? dropdown2Value;
  final List<Task> tasks;

  const SaveToXmlButton({
    super.key,
    required this.dropdown1Value,
    required this.dropdown2Value,
    required this.tasks,
  });

  Future<void> _handleSave(BuildContext context) async {
    try {
      // Convert tasks and subtasks for XML
      final List<Map<String, dynamic>> tasksList = tasks.map((task) => {
        'id': task.id,
        'title': task.title,
        'description': task.description ?? '',
        'status': task.isCompleted.toString(),
      }).toList();

      final List<Map<String, dynamic>> subtasksList = tasks.expand((task) => 
        task.subtasks.map((subtask) => {
          'title': subtask.title,
          'parentTaskId': task.id,
          'status': subtask.isCompleted.toString(),
        })
      ).toList();

      // Save to XML
      await XmlService.saveToXml(
        dropdown1Value: dropdown1Value,
        dropdown2Value: dropdown2Value,
        tasks: tasksList,
        subtasks: subtasksList,
      );

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully saved to regist.xml'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving to regist.xml: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PurpleButton(
      onPressed: () => _handleSave(context),
      text: '',
    );
  }
}
