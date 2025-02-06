import 'dart:io';
import 'package:flutter/material.dart';

class SaveWidget extends StatefulWidget {
  const SaveWidget({Key? key}) : super(key: key);

  @override
  _SaveWidgetState createState() => _SaveWidgetState();
}

class _SaveWidgetState extends State<SaveWidget> {
  final TextEditingController _controller = TextEditingController();
  String? _currentDescription;

  Future<void> _saveText() async {
    try {
      final text = _controller.text;
      final directory = Directory(r'C:\Users\cesar\Documents\assets');
      final file = File(r'C:\Users\cesar\Documents\assets\projects.xml');

      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Read existing content or create new XML structure
      String xmlContent;
      if (await file.exists()) {
        xmlContent = await file.readAsString();
        // Remove last </projects> tag to append new entry
        xmlContent = xmlContent.replaceAll('</projects>', '');
      } else {
        xmlContent = '<?xml version="1.0" encoding="UTF-8"?>\n<projects>\n';
      }

      // Add new project entry with description tag
      xmlContent += '  <project>\n    <description>${text.trim()}</description>\n  </project>\n</projects>';

      // Write updated content
      await file.writeAsString(xmlContent);
      
      // Clear text field after successful save
      _controller.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully saved to projects.xml')),
        );
      }
      // Refresh the current description after saving
      await _loadCurrentDescription();
      setState(() {
        _currentDescription = _currentDescription;
      }); // Trigger a rebuild to update the button color
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: \$e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentDescription();
  }

  Future<void> _loadCurrentDescription() async {
    try {
      final file = File(r'C:\Users\cesar\Documents\assets\projects.xml');
      if (await file.exists()) {
        final content = await file.readAsString();
        final regExp = RegExp(r'<description>(.*?)</description>');
        final matches = regExp.allMatches(content);
        if (matches.isNotEmpty) {
          final lastMatch = matches.last;
          setState(() {
            _currentDescription = lastMatch.group(1)?.trim();
          });
        } else {
          setState(() {
            _currentDescription = '';
          });
        }
      } else {
        setState(() {
          _currentDescription = '';
        });
      }
    } catch (e) {
      setState(() {
        _currentDescription = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Enter text to save',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _loadCurrentDescription,
                child: Text(_currentDescription ?? 'No description'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveText,
                child: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.brown, // Set background color to brown
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
