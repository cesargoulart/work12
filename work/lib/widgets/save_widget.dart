import 'dart:io';
import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../features/handle_save_with_description.dart';

class SaveWidget extends StatefulWidget {
  final List<bool> checkboxStates;
  final Function(List<bool>) onCheckboxesUpdate;

  const SaveWidget({
    Key? key,
    required this.checkboxStates,
    required this.onCheckboxesUpdate,
  }) : super(key: key);

  @override
  _SaveWidgetState createState() => _SaveWidgetState();
}

class _SaveWidgetState extends State<SaveWidget> {
  final TextEditingController _controller = TextEditingController();
  String? _currentDescription;

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

    xmlContent += '''  <project>
    <description>${text.trim()}</description>
    <checkboxes>
      <checkbox>
        <label>MR REC</label>
        <value>${widget.checkboxStates[0]}</value>
      </checkbox>
      <checkbox>
        <label>MR PKG</label>
        <value>${widget.checkboxStates[1]}</value>
      </checkbox>
      <checkbox>
        <label>COM</label>
        <value>${widget.checkboxStates[2]}</value>
      </checkbox>
      <checkbox>
        <label>DEV1</label>
        <value>${widget.checkboxStates[3]}</value>
      </checkbox>
      <checkbox>
        <label>DEV2</label>
        <value>${widget.checkboxStates[4]}</value>
      </checkbox>
      <checkbox>
        <label>REC1</label>
        <value>${widget.checkboxStates[5]}</value>
      </checkbox>
      <checkbox>
        <label>REC2</label>
        <value>${widget.checkboxStates[6]}</value>
      </checkbox>
    </checkboxes>
  </project>
</projects>''';
    await file.writeAsString(xmlContent);
  }

  Future<void> _saveText() async {
    try {
      final directory = Directory(r'C:\Users\cesar\Documents\assets');
      final file = File(r'C:\Users\cesar\Documents\assets\projects.xml');

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final text = _controller.text.trim();

      // If we have currentDescription, always update that project
      if (_currentDescription != null && _currentDescription!.isNotEmpty) {
        final handleSave = HandleSaveWithDescription();
        final project = Project(
          description: _currentDescription!, 
          checkboxes: widget.checkboxStates.asMap().entries.map((e) {
            final label = e.key == 0 ? 'MR REC' :
                         e.key == 1 ? 'MR PKG' :
                         e.key == 2 ? 'COM' :
                         e.key == 3 ? 'DEV1' :
                         e.key == 4 ? 'DEV2' :
                         e.key == 5 ? 'REC1' :
                         'REC2';
            return CheckboxModel(
              label: label,
              value: e.value
            );
          }).toList()
        );
        
        await handleSave.execute(
          currentDescription: _currentDescription!,
          selectedProject: project,
          checkboxStates: widget.checkboxStates
        );
      } 
      // Only create new project if we have new text and no currentDescription
      else if (text.isNotEmpty) {
        await _createNewDescription(text, file);
      }
      // Don't create empty projects
      else {
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
        final regExp = RegExp(r'<description>(.*?)</description>(?!.*<description>)');
        final match = regExp.firstMatch(content);

        if (match != null) {
          setState(() {
            _currentDescription = match.group(1)?.trim() ?? '';
          });

          // Find project with this description and load its checkbox states
          final projectRegExp = RegExp(
            r'<project>.*?<description>(.*?)</description>.*?</project>', 
            dotAll: true
          );
          
          for (var match in projectRegExp.allMatches(content)) {
            final descriptionMatch = match.group(1)?.trim();
            if (descriptionMatch == _currentDescription) {
              final projectContent = match.group(0) ?? '';
              final checkboxValues = RegExp(r'<value>(true|false)</value>')
                  .allMatches(projectContent)
                  .map((m) => m.group(1) == 'true')
                  .toList();
              
              if (checkboxValues.length == 7) {
                widget.onCheckboxesUpdate(checkboxValues);
                break;
              }
            }
          }
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
