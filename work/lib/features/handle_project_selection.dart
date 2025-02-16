import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/xml_service.dart';
import 'update_checkboxes.dart';

class ProjectSelectionHandler {
  static Future<void> handleProjectSelection(String description) async {
    try {
      // Load project from XML
      final Project? project = await XmlService.loadProjectByDescription(description);
      
      if (project != null) {
        // Update checkboxes with animation
        updateCheckboxes(project.checkboxes);
      } else {
        print('Project not found for description: $description');
      }
    } catch (e) {
      print('Error handling project selection: $e');
    }
  }
}
