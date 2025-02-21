import 'package:flutter/material.dart';

class PurpleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;

  const PurpleButton({
    super.key, 
    required this.onPressed, 
    this.text = 'Text'
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
      ),
      onPressed: onPressed,
      child: Text(text ?? ''),
    );
  }
}
