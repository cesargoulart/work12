import 'package:flutter/material.dart';
import 'animated_icon_button.dart';

class AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onHelpPressed;

  const AnimatedSearchBar({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onHelpPressed,
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: 'Enter text here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        AnimatedIconButton(
          icon: Icons.save_rounded,
          label: 'Save',
          onTap: widget.onSave,
        ),
        const SizedBox(width: 12),
        AnimatedIconButton(
          icon: Icons.help_outline_rounded,
          label: 'H',
          onTap: widget.onHelpPressed,
          backgroundColor: Colors.grey[800],
        ),
      ],
    );
  }
}