import 'package:flutter/material.dart';
import 'animated_dropdown.dart';

class DropdownRow extends StatelessWidget {
  final String? firstValue;
  final String? secondValue;
  final Function(String?) onFirstChanged;
  final Function(String?) onSecondChanged;
  final List<String> firstItems;
  final List<String> secondItems;

  const DropdownRow({
    super.key,
    required this.firstValue,
    required this.secondValue,
    required this.onFirstChanged,
    required this.onSecondChanged,
    required this.firstItems,
    required this.secondItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Expanded(
            child: AnimatedDropdown(
              hint: 'Select first option',
              items: firstItems,
              value: firstValue,
              onChanged: onFirstChanged,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimatedDropdown(
              hint: 'Select second option',
              items: secondItems,
              value: secondValue,
              onChanged: onSecondChanged,
            ),
          ),
        ],
      ),
    );
  }
}