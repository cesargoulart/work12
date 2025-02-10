import 'package:flutter/material.dart';

class PurpleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PurpleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
      ),
      onPressed: onPressed,
      child: const Text('Purple'),
    );
  }
}