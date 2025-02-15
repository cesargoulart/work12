import 'package:flutter/material.dart';
import '../services/xml_service.dart';
import '../widgets/animated_descriptions_list.dart';
import 'update_checkboxes.dart';

void handleGreenButtonPress(BuildContext context) async {
  final descriptions = await XmlService.loadProjectDescriptions();
  print('Descriptions loaded: \$descriptions');
  print('Descriptions loaded: \$descriptions');
  
  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return AnimatedDescriptionsList(
          descriptions: descriptions,
          onClose: () => Navigator.of(context).pop(),
          onSelect: (selectedDescription) async {
            // Handle the selection and update the checkboxes
            final selectedProject = await XmlService.loadProjectByDescription(selectedDescription);
            if (selectedProject != null) {
            if (selectedProject != null) {
              // Update the checkboxes based on the selected project
              // Assuming you have a method to update the checkboxes in your app
              updateCheckboxes(selectedProject.checkboxes);
            }
            }
          },
        );
      },
    );
  }
}
