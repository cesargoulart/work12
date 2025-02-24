import 'package:flutter/material.dart';

class PurpleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;

  const PurpleButton({
    super.key,
    required this.onPressed,
    this.text = 'Text',
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadowColor: primaryColor.withOpacity(0.3),
        elevation: 8,
      ),
      onPressed: onPressed,
      child: Text(
        text ?? '',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
