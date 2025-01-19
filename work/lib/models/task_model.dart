// lib/models/task_model.dart

import 'subtask_model.dart';



class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  bool isCompleted;
  bool isExpanded;
  List<Subtask> subtasks;  // Added this line

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.isCompleted = false,
    this.isExpanded = false,
    List<Subtask>? subtasks,  // Added this parameter
  }) : subtasks = subtasks ?? [];  // Initialize with empty list if null
}