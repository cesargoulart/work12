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

  Future<void> _updateExistingDescription(String text, File file) async {
    try {
      String xmlContent = await file.readAsString();
      // Use non-greedy match and positive lookahead to find last description
      final regExp = RegExp(r'(<description>)(.*?)(<\/description>)(?!.*<description>)');
      final match = regExp.firstMatch(xmlContent);

      if (match != null) {
        final updatedContent = xmlContent.replaceFirst(
          regExp,
          '${match.group(1)}${text.trim()}${match.group(3)}'
        );
        await file.writeAsString(updatedContent);
        return;
      }
      throw Exception('No matching description found to update');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _createNewDescription(String text, File file) async {
    String xmlContent;
    if (await file.exists()) {
      xmlContent = await file.readAsString();
      if (!xmlContent.trim().endsWith('</projects>')) {
        xmlContent = '<?xml version="1.0" encoding="UTF-8"?>\n<projects>\n';
      } else {
        xmlContent = xmlContent.substring(0, xmlContent.lastIndexOf('</projects>'));
      }
    } else {
      xmlContent = '<?xml version="1.0" encoding="UTF-8"?>\n<projects>\n';
    }

    xmlContent += '  <project>\n    <description>${text.trim()}</description>\n  </project>\n</projects>';
    await file.writeAsString(xmlContent);
  }

  Future<void> _saveText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter some text before saving'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final directory = Directory(r'C:\Users\cesar\Documents\assets');
      final file = File(r'C:\Users\cesar\Documents\assets\projects.xml');

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      if (_currentDescription != null && _currentDescription!.isNotEmpty) {
        await _updateExistingDescription(text, file);
      } else {
        await _createNewDescription(text, file);
      }
      
      _controller.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully saved to projects.xml'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _loadCurrentDescription();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving file: $e'),
            backgroundColor: Colors.red,
          ),
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
        // Use non-greedy match and negative lookahead for last description
        final regExp = RegExp(r'<description>(.*?)<\/description>(?!.*<description>)');
        final match = regExp.firstMatch(content);
        setState(() {
          _currentDescription = match?.group(1)?.trim() ?? '';
        });
      } else {
        setState(() {
          _currentDescription = '';
        });
      }
    } catch (e) {
      setState(() {
        _currentDescription = '';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading description: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            border: OutlineInputBorder(),
          ),
          maxLines: null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _currentDescription != null && _currentDescription!.isNotEmpty 
                  ? () => _controller.text = _currentDescription!
                  : _loadCurrentDescription,
                child: Text(
                  _currentDescription?.isNotEmpty == true 
                    ? _currentDescription! 
                    : 'No description'
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: _currentDescription != null && _currentDescription!.isNotEmpty
                      ? Colors.deepPurple.shade300
                      : null,
                  foregroundColor: _currentDescription != null && _currentDescription!.isNotEmpty
                      ? Colors.white
                      : null,
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
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
