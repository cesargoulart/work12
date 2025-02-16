import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'animated_icon_button.dart';
import '../features/handle_description_updates.dart';

class AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onHelpPressed;
  final void Function(String)? onChanged;

  const AnimatedSearchBar({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onHelpPressed,
    this.onChanged,
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  final _descriptionHandler = DescriptionUpdateHandler();
  StreamSubscription<String>? _descriptionSubscription;
  String _currentDescription = 'No description';

  @override
  void initState() {
    super.initState();
    _currentDescription = _descriptionHandler.getCurrentDescription();
    _descriptionSubscription = _descriptionHandler.descriptionStream.listen((description) {
      setState(() {
        _currentDescription = description;
      });
    });
  }

  @override
  void dispose() {
    _descriptionSubscription?.cancel();
    super.dispose();
  }

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
              onChanged: widget.onChanged,
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
          icon: Icons.description,
          label: _currentDescription,
          onTap: () async {
            // No need to do anything here as description updates come through stream
          },
          backgroundColor: Colors.brown,
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
          backgroundColor: Colors.green,
        ),
      ],
    );
  }
}
