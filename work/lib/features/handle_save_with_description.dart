import 'dart:io';
import '../models/project_model.dart';
import '../widgets/animated_checkbox_group.dart';
import '../services/xml_service.dart';

class HandleSaveWithDescription {
  
  Future<void> execute({
    required String currentDescription,
    required Project? selectedProject,
    required List<bool> checkboxStates,
  }) async {
    if (currentDescription.isEmpty || selectedProject == null) {
      return;
    }

    final file = File(XmlService.projectsPath);
    if (!await file.exists()) {
      throw Exception('Projects file not found');
    }

    String xmlContent = await file.readAsString();
    
    // Find all projects
    final projectRegExp = RegExp(r'<project>.*?</project>', dotAll: true);
    final descRegExp = RegExp(r'<description>(.*?)</description>');
    
    bool found = false;
    final updatedContent = xmlContent.replaceAllMapped(projectRegExp, (match) {
      final projectText = match.group(0) ?? '';
      final descMatch = descRegExp.firstMatch(projectText);
      final description = descMatch?.group(1)?.trim();
      
      if (description == currentDescription.trim()) {
        found = true;
        // Update this specific project but keep its description from the XML
        return '''  <project>
    <description>${description}</description>
    <checkboxes>
      <checkbox>
        <label>MR REC</label>
        <value>${checkboxStates[0]}</value>
      </checkbox>
      <checkbox>
        <label>MR PKG</label>
        <value>${checkboxStates[1]}</value>
      </checkbox>
      <checkbox>
        <label>COM</label>
        <value>${checkboxStates[2]}</value>
      </checkbox>
      <checkbox>
        <label>DEV1</label>
        <value>${checkboxStates[3]}</value>
      </checkbox>
      <checkbox>
        <label>DEV2</label>
        <value>${checkboxStates[4]}</value>
      </checkbox>
      <checkbox>
        <label>REC1</label>
        <value>${checkboxStates[5]}</value>
      </checkbox>
      <checkbox>
        <label>REC2</label>
        <value>${checkboxStates[6]}</value>
      </checkbox>
    </checkboxes>
  </project>''';
      }
      return match.group(0) ?? '';
    });

    if (!found) {
      throw Exception('Project with description "$currentDescription" not found');
    }

    await file.writeAsString(updatedContent);
  }
}
