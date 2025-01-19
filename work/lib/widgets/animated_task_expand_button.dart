// lib/widgets/animated_task_expand_button.dart
import 'package:flutter/material.dart';

class AnimatedTaskExpandButton extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  const AnimatedTaskExpandButton({
    super.key,
    required this.isExpanded,
    required this.onPressed,
    required this.onLongPress,
  });

  @override
  State<AnimatedTaskExpandButton> createState() => _AnimatedTaskExpandButtonState();
}

class _AnimatedTaskExpandButtonState extends State<AnimatedTaskExpandButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.25,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedTaskExpandButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        if (!widget.isExpanded) {
          _controller.reverse();
        }
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          print('Button tapped - Expand/Collapse');
          widget.onPressed();
        },
        onLongPress: () {
          print('Button long pressed - Add subtask');
          widget.onLongPress();
        },
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isHovering 
                ? Theme.of(context).primaryColor.withOpacity(0.2)
                : Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          child: Tooltip(
            message: 'Click to expand, long press to add subtask',
            child: Center(
              child: RotationTransition(
                turns: _rotationAnimation,
                child: Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: _isHovering 
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}