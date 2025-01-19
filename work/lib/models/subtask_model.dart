// lib/models/subtask_model.dart
class Subtask {
  final String id;
  final String taskId;
  final String title;
  bool isCompleted;
  final DateTime createdAt;

  Subtask({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });
}