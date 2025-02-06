import 'dart:io';
import 'package:flutter/material.dart';
import 'animated_icon_button.dart';

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
  Future<String> _loadCurrentDescription() async {
    try {
      final file = File(r'C:\Users\cesar\Documents\assets\projects.xml');
      if (await file.exists()) {
        final content = await file.readAsString();
        final regExp = RegExp(r'<description>(.*?)</description>');
        final matches = regExp.allMatches(content);
        if (matches.isNotEmpty) {
          final lastMatch = matches.last;
          return lastMatch.group(1)?.trim() ?? 'No description';
        }
      }
      return 'No description';
    } catch (e) {
      return 'Error loading description';
    }
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
        FutureBuilder<String>(
          future: _loadCurrentDescription(),
          builder: (context, snapshot) {
            return AnimatedIconButton(
              icon: Icons.description,
              label: snapshot.data ?? 'No description',
              onTap: () async {
                setState(() {});  // Trigger rebuild to refresh description
              },
              backgroundColor: Colors.brown,
            );
          },
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
