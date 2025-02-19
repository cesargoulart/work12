import 'dart:io';
import 'package:xml/xml.dart';
import 'package:flutter/material.dart';

class SaveHandler {
  static const String _filePath = r'C:\Users\cesar\Documents\assets\projects.xml';
  
  static Future<void> saveToXml({
    required Map<String, bool> checkboxValues,
    required String text,
    required BuildContext context,
  }) async {
    try {
      // Validation
      if (!_validateInput(checkboxValues, text)) {
        _showMessage(
          context,
          'Please select at least one option or enter text',
          isError: true,
        );
        return;
      }

      final directory = Directory(r'C:\Users\cesar\Documents\assets');
      await _ensureDirectoryExists(directory);

      // Load or create document
      final document = await _loadOrCreateDocument();
      
      // Create new project element
      final projectElement = await _createProjectElement(text, checkboxValues);
      
      // Add to document safely
      await _addProjectToDocument(document, projectElement);

      // Save file
      await _saveDocument(document);
      
      _showMessage(context, 'Successfully saved to projects.xml');
    } catch (e) {
      _showMessage(context, 'Error saving file: $e', isError: true);
    }
  }

  static bool _validateInput(Map<String, bool> checkboxValues, String text) {
    return checkboxValues.values.any((value) => value) || text.isNotEmpty;
  }

  static Future<void> _ensureDirectoryExists(Directory directory) async {
    if (!await directory.exists()) {
      await directory.create(recursive: true);
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
    
    // Add description
    projectElement.children.addAll([
      XmlText('\n    '),
      XmlElement(XmlName('description'))..children.add(XmlText(text)),
      XmlText('\n    '),
    ]);

    // Add checkboxes
    final checkboxesElement = XmlElement(XmlName('checkboxes'));
    
    // Create a List of MapEntry objects to avoid concurrent modification
    final checkboxEntries = checkboxValues.entries.toList();
    
    for (var entry in checkboxEntries) {
      checkboxesElement.children.add(XmlText('\n      '));
      
      final checkboxElement = XmlElement(XmlName('checkbox'));
      checkboxElement.children.addAll([
        XmlText('\n        '),
        XmlElement(XmlName('label'))..children.add(XmlText(entry.key)),
        XmlText('\n        '),
        XmlElement(XmlName('value'))..children.add(XmlText(entry.value.toString())),
        XmlText('\n      '),
      ]);
      
      checkboxesElement.children.add(checkboxElement);
    }
    
    checkboxesElement.children.add(XmlText('\n    '));
    projectElement.children.add(checkboxesElement);
    projectElement.children.add(XmlText('\n  '));
    
    return projectElement;
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