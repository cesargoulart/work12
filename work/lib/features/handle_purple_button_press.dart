import 'package:flutter/material.dart';
import 'save_textbox_to_regist.dart';

class HandlePurpleButtonPress {
  static final TextEditingController textController = TextEditingController();

  static void updateText(String newText) {
    textController.text = newText;
  }

  static void setText(String? text) {
    textController.text = text ?? '';
  }

  static Future<void> handlePress() async {
    try {
      await SaveTextboxToRegist.saveText(textController.text);
    } catch (e) {
      print('Error saving text: $e');
    }
  }
}
