class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.isCompleted = false,
  });
}