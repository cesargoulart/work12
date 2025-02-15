import 'package:flutter/material.dart';
import '../services/xml_service.dart';
import '../widgets/animated_descriptions_list.dart';

void handleGreenButtonPress(BuildContext context) async {
  final descriptions = await XmlService.loadProjectDescriptions();
  
  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return AnimatedDescriptionsList(
          descriptions: descriptions,
          onClose: () => Navigator.of(context).pop(),
        );
      },
    );
  }
}
