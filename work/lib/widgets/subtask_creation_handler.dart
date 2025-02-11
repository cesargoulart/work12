import 'package:flutter/material.dart';

class SubtaskCreationHandler extends StatelessWidget {
  final String taskId;
  final void Function(String taskId, String subtaskTitle) onSubtaskCreated;

  const SubtaskCreationHandler({
    Key? key,
    required this.taskId,
    required this.onSubtaskCreated,
  }) : super(key: key);

  void _handleAddSubtask(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add Subtask'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter subtask title',
            labelText: 'Subtask Title',
          ),
          onSubmitted: (String value) {
            if (value.isNotEmpty) {
              onSubtaskCreated(taskId, value);
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text;
              if (text.isNotEmpty) {
                onSubtaskCreated(taskId, text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () => _handleAddSubtask(context),
      tooltip: 'Add Subtask',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      alignment: Alignment.centerLeft,
      iconSize: 20, // Make the icon a bit smaller
    );
  }
}
