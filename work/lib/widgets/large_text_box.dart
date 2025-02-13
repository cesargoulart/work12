import 'package:flutter/material.dart';

class LargeTextBox extends StatelessWidget {
  const LargeTextBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[800], // Darker theme
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        maxLines: null, // Allows for multiple lines
        keyboardType: TextInputType.multiline,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: 'Enter text here...',
          hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal),
          border: InputBorder.none,
        ),
      ),
    );
  }
}