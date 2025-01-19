// lib/widgets/animated_task_list.dart
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/subtask_model.dart';
import '../helpers/task_status_helper.dart';
import 'animated_task_expand_button.dart';
import 'animated_subtask_list.dart';
import 'animated_subtask_dialog.dart';

class AnimatedTaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(String) onTaskToggle;
  final Function(String) onTaskDelete;
  final Function(String) onTaskExpand;
  final Function(String, String) onSubtaskCreated;
  final Function(String, String) onSubtaskToggle;

  const AnimatedTaskList({
    super.key,
    required this.tasks,
    required this.onTaskToggle,
    required this.onTaskDelete,
    required this.onTaskExpand,
    required this.onSubtaskCreated,
    required this.onSubtaskToggle,
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
          key: ValueKey(task.id),
          task: task,
          onToggle: () => onTaskToggle(task.id),
          onDelete: () => onTaskDelete(task.id),
          onExpand: () => onTaskExpand(task.id),
          onSubtaskCreated: onSubtaskCreated,
          onSubtaskToggle: onSubtaskToggle,
        );
      },
    );
  }
}

class AnimatedTaskItem extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onExpand;
  final Function(String, String) onSubtaskCreated;
  final Function(String, String) onSubtaskToggle;

  const AnimatedTaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onExpand,
    required this.onSubtaskCreated,
    required this.onSubtaskToggle,
  });

  @override
  State<AnimatedTaskItem> createState() => _AnimatedTaskItemState();
}

class _AnimatedTaskItemState extends State<AnimatedTaskItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _heightAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isHovering = false;

  void _showSubtaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AnimatedSubtaskDialog(
        taskId: widget.task.id,
        onSubtaskCreated: widget.onSubtaskCreated,
      ),
    );
  }

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

    _heightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: TaskStatusHelper.hasUncompletedSubtasks(widget.task)
          ? Colors.yellow[50]
          : Colors.white,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.task.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedTaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: TaskStatusHelper.hasUncompletedSubtasks(widget.task)
          ? Colors.yellow[50]
          : Colors.white,
    ).animate(
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
    final hasUncompleted = TaskStatusHelper.hasUncompletedSubtasks(widget.task);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                // Always yellow when has uncompleted subtasks
                color: hasUncompleted ? const Color.fromARGB(255, 255, 243, 231) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: hasUncompleted
                        ? Colors.yellow.withOpacity(0.2)
                        : Colors.black.withOpacity(_isHovering ? 0.1 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedTaskExpandButton(
                          isExpanded: widget.task.isExpanded,
                          onPressed: widget.onExpand,
                          onLongPress: _showSubtaskDialog,
                        ),
                        const SizedBox(width: 12),
                        Checkbox(
                          value: widget.task.isCompleted,
                          onChanged: (_) => widget.onToggle(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
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
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: widget.task.description != null &&
                            !widget.task.isExpanded
                        ? Text(
                            widget.task.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.task.isCompleted
                                  ? Colors.grey
                                  : Colors.black54,
                            ),
                          )
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red.withOpacity(0.8),
                      onPressed: widget.onDelete,
                    ),
                  ),
                  if (widget.task.isExpanded)
                    AnimatedBuilder(
                      animation: _heightAnimation,
                      builder: (context, child) {
                        return SizeTransition(
                          sizeFactor: _heightAnimation,
                          child: Column(
                            children: [
                              if (widget.task.description != null)
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(76, 0, 20, 16),
                                  width: double.infinity,
                                  child: Text(
                                    widget.task.description!,
                                    style: TextStyle(
                                      color: widget.task.isCompleted
                                          ? Colors.grey
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                              if (widget.task.subtasks.isNotEmpty)
                                AnimatedSubtaskList(
                                  subtasks: widget.task.subtasks,
                                  onSubtaskToggle: (subtaskId) =>
                                      widget.onSubtaskToggle(
                                          widget.task.id, subtaskId),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
