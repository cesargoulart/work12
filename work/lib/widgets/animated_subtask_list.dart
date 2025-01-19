// lib/widgets/animated_subtask_list.dart
import 'package:flutter/material.dart';
import '../models/subtask_model.dart';

class AnimatedSubtaskList extends StatelessWidget {
  final List<Subtask> subtasks;
  final Function(String subtaskId) onSubtaskToggle;

  const AnimatedSubtaskList({
    super.key,
    required this.subtasks,
    required this.onSubtaskToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: subtasks.map((subtask) => AnimatedSubtaskItem(
          key: ValueKey(subtask.id),
          subtask: subtask,
          onToggle: () => onSubtaskToggle(subtask.id),
        )).toList(),
      ),
    );
  }
}

class AnimatedSubtaskItem extends StatefulWidget {
  final Subtask subtask;
  final VoidCallback onToggle;

  const AnimatedSubtaskItem({
    super.key,
    required this.subtask,
    required this.onToggle,
  });

  @override
  State<AnimatedSubtaskItem> createState() => _AnimatedSubtaskItemState();
}

class _AnimatedSubtaskItemState extends State<AnimatedSubtaskItem>
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
          margin: const EdgeInsets.only(left: 76, top: 4, bottom: 4, right: 20),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: widget.subtask.isCompleted,
                  onChanged: (_) => widget.onToggle(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.subtask.title,
                  style: TextStyle(
                    decoration: widget.subtask.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color:
                        widget.subtask.isCompleted ? Colors.grey : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}