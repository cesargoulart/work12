import 'package:flutter/material.dart';

class AnimatedTaskExpandButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  const AnimatedTaskExpandButton({
    Key? key,
    required this.isExpanded,
    required this.onPressed,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress, // Long press to add subtask
      child: IconButton(
        icon: Icon(
          Icons.add, // Always show plus sign
          size: 24,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        splashRadius: 24,
      ),
    );
  }
}
