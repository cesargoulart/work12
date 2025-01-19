// lib/helpers/task_status_helper.dart
import '../models/task_model.dart';

class TaskStatusHelper {
  static bool hasUncompletedSubtasks(Task task) {
    if (task.subtasks.isEmpty) return false;
    return task.subtasks.any((subtask) => !subtask.isCompleted);
  }
}