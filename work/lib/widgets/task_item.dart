import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'subtask_creation_handler.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onExpand;
  final Function(String taskId, String subtaskTitle) onAddSubtask;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onExpand,
    required this.onAddSubtask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Add subtask button at the beginning
        SubtaskCreationHandler(
          taskId: task.id,
          onSubtaskCreated: onAddSubtask,
        ),
        Expanded(
          child: ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (_) => onToggle(),
              activeColor: Colors.deepPurple,
              side: const BorderSide(
                color: Colors.black,
                width: 2.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            title: Text(task.title),
            subtitle: task.description != null ? Text(task.description!) : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.expand_more),
                  onPressed: onExpand,
                  tooltip: 'Expand Task',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                  tooltip: 'Delete Task',
                ),
              ],
            ),
            onTap: onToggle,
          ),
        ),
      ],
    );
  }
}
