import 'package:flutter/material.dart';

class LargeTextBox extends StatefulWidget {
  final Function(String) onTextChanged;
  final String? initialText;
  final TextEditingController? controller;
  
  const LargeTextBox({
    super.key,
    required this.onTextChanged,
    this.initialText,
    this.controller,
  });

  @override
  State<LargeTextBox> createState() => _LargeTextBoxState();
}

class _LargeTextBoxState extends State<LargeTextBox> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialText);
  }

  @override
  void didUpdateWidget(LargeTextBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && widget.initialText != oldWidget.initialText) {
      _controller.text = widget.initialText ?? '';
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

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
      child: SizedBox(
        height: 150, // You can adjust this value
        child: SingleChildScrollView(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Enter text here...',
          hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal),
          border: InputBorder.none,
        ),
        onChanged: widget.onTextChanged,
      ),
    );
  }
}
