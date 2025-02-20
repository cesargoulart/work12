import 'dart:io';
import 'package:xml/xml.dart';
import 'package:flutter/material.dart';

class SaveHandler {
  static const String _filePath = r'C:\Users\cesar\Documents\assets\projects.xml';
  
  static Future<void> saveToXml({
    required Map<String, bool> checkboxValues,
    required String text,
    required BuildContext context,
    String? currentDescription,
  }) async {
    try {
      // If there's no current description and no new text, don't create a new project.
      if ((currentDescription == null || currentDescription.isEmpty) && text.isEmpty) {
        _showMessage(context, 'Please enter some text before saving', isError: true);
        return;
      }

      final directory = Directory(r'C:\Users\cesar\Documents\assets');
      await _ensureDirectoryExists(directory);

      // Load or create the XML document.
      final document = await _loadOrCreateDocument();

      bool projectUpdated = false;
      if (currentDescription != null && currentDescription.isNotEmpty) {
        // Try to find and update the existing project with this description.
        final projectsRoot = document.findAllElements('projects').first;
        for (var project in projectsRoot.findElements('project')) {
          final descriptionElement = project.getElement('description');
          if (descriptionElement != null && descriptionElement.text == currentDescription) {
            // Update description only if new text is provided.
            if (text.isNotEmpty) {
              descriptionElement.innerText = text;
            }

            // Create a new <checkboxes> node with updated states.
            final newCheckboxes = _createCheckboxesElement(checkboxValues);

            // Remove the old <checkboxes> node (if any) from the project.
            final oldCheckboxes = project.getElement('checkboxes');
            if (oldCheckboxes != null) {
              project.children.remove(oldCheckboxes);
            }

            // Add the new <checkboxes> node to the project.
            project.children.add(newCheckboxes);

            projectUpdated = true;
            break;
          }
        }
      }

      // If no existing project was updated, create a new one only if text is provided.
      if (!projectUpdated) {
        if (text.isNotEmpty) {
          final projectElement = await _createProjectElement(text, checkboxValues);
          await _addProjectToDocument(document, projectElement);
        }
      }

      // Save the updated document.
      await _saveDocument(document);
      _showMessage(context, 'Successfully saved to projects.xml');
    } catch (e) {
      _showMessage(context, 'Error saving file: $e', isError: true);
    }
  }

  static Future<XmlDocument> _loadOrCreateDocument() async {
    final file = File(_filePath);
    if (await file.exists()) {
      final xmlString = await file.readAsString();
      return XmlDocument.parse(xmlString);
    }
    
    return XmlDocument([
      XmlProcessing('xml', 'version="1.0" encoding="UTF-8"'),
      XmlElement(XmlName('projects'))
    ]);
  }

  static Future<XmlElement> _createProjectElement(
    String text,
    Map<String, bool> checkboxValues,
  ) async {
    final projectElement = XmlElement(XmlName('project'));
    
    // Add description.
    projectElement.children.addAll([
      XmlText('\n    '),
      XmlElement(XmlName('description'))..children.add(XmlText(text)),
      XmlText('\n    '),
    ]);

    // Add checkboxes using helper.
    final checkboxesElement = _createCheckboxesElement(checkboxValues);
    projectElement.children.add(checkboxesElement);
    projectElement.children.add(XmlText('\n  '));
    
    return projectElement;
  }

  static XmlElement _createCheckboxesElement(Map<String, bool> checkboxValues) {
    final checkboxesElement = XmlElement(XmlName('checkboxes'));
    checkboxValues.forEach((key, value) {
      checkboxesElement.children.add(XmlText('\n      '));
      final checkboxElement = XmlElement(XmlName('checkbox'));
      checkboxElement.children.addAll([
        XmlText('\n        '),
        XmlElement(XmlName('label'))..children.add(XmlText(key)),
        XmlText('\n        '),
        XmlElement(XmlName('value'))..children.add(XmlText(value.toString())),
        XmlText('\n      '),
      ]);
      checkboxesElement.children.add(checkboxElement);
    });
    checkboxesElement.children.add(XmlText('\n    '));
    return checkboxesElement;
  }

  static Future<void> _addProjectToDocument(
    XmlDocument document,
    XmlElement projectElement,
  ) async {
    final projectsRoot = document.findAllElements('projects').first;
    projectsRoot.children.add(XmlText('\n  '));
    projectsRoot.children.add(projectElement);
    projectsRoot.children.add(XmlText('\n'));
  }

  static Future<void> _saveDocument(XmlDocument document) async {
    final file = File(_filePath);
    await file.writeAsString(document.toXmlString(pretty: true));
  }

  static Future<void> _ensureDirectoryExists(Directory directory) async {
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  static void _showMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}
