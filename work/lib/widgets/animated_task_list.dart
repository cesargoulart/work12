import 'package:flutter/material.dart';
import '../models/task_model.dart';

class AnimatedTaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(String) onTaskToggle;
  final Function(String) onTaskDelete;

  const AnimatedTaskList({
    super.key,
    required this.tasks,
    required this.onTaskToggle,
    required this.onTaskDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return AnimatedTaskItem(
          task: task,
          onToggle: () => onTaskToggle(task.id),
          onDelete: () => onTaskDelete(task.id),
        );
      },
    );
  }
}

class AnimatedTaskItem extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const AnimatedTaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<AnimatedTaskItem> createState() => _AnimatedTaskItemState();
}

class _AnimatedTaskItemState extends State<AnimatedTaskItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            title: Text(
              widget.task.title,
              style: TextStyle(
                decoration: widget.task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: widget.task.isCompleted
                    ? Colors.grey
                    : Colors.black87,
              ),
            ),
            subtitle: widget.task.description != null
                ? Text(
                    widget.task.description!,
                    style: TextStyle(
                      color: widget.task.isCompleted
                          ? Colors.grey
                          : Colors.black54,
                    ),
                  )
                : null,
            leading: Checkbox(
              value: widget.task.isCompleted,
              onChanged: (_) => widget.onToggle(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red.withOpacity(0.8),
              onPressed: widget.onDelete,
            ),
          ),
        ),
      ),
    );
  }
}