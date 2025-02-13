import '../services/xml_service.dart';
import 'package:xml/xml.dart';
import 'dart:io';

class SaveTextboxToRegist {
  static Future<void> saveText(String text) async {
    try {
      final file = File(XmlService.registPath);
      XmlDocument document;
      
      // Create or load the XML document
      if (await file.exists()) {
        final xmlString = await file.readAsString();
        try {
          document = XmlDocument.parse(xmlString);
        } catch (e) {
          document = _createNewDocument();
        }
      } else {
        document = _createNewDocument();
      }

      // Create or update textContent element
      var mainGroup = document.rootElement.findElements('mainGroup').firstOrNull;
      if (mainGroup == null) {
        mainGroup = XmlElement(XmlName('mainGroup'));
        document.rootElement.children.add(XmlText('\n  '));
        document.rootElement.children.add(mainGroup);
      }

      var textContent = mainGroup.findElements('textContent').firstOrNull;
      if (textContent == null) {
        textContent = XmlElement(XmlName('textContent'));
        mainGroup.children.add(XmlText('\n    '));
        mainGroup.children.add(textContent);
      }

      // Update text content
      textContent.children.clear();
      textContent.children.add(XmlText(text));
      
      // Add final formatting
      mainGroup.children.add(XmlText('\n  '));
      document.rootElement.children.add(XmlText('\n'));

      // Save with proper formatting
      final prettyXml = document.toXmlString(pretty: true, indent: '  ');
      await file.writeAsString(prettyXml);
    } catch (e) {
      print('Error saving text to regist.xml: $e');
      rethrow;
    }
  }

  static XmlDocument _createNewDocument() {
    return XmlDocument([
      XmlProcessing('xml', 'version="1.0" encoding="UTF-8"'),
      XmlElement(XmlName('registData')),
    ]);
  }
}
