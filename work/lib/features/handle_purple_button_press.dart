import 'package:flutter/material.dart';
import 'save_textbox_to_regist.dart';

class HandlePurpleButtonPress {
  static final ValueNotifier<String> textNotifier = ValueNotifier<String>('');

  static void updateText(String newText) {
    textNotifier.value = newText;
  }

  static Future<void> handlePress() async {
    try {
      await SaveTextboxToRegist.saveText(textNotifier.value);
    } catch (e) {
      print('Error saving text: $e');
    }
  }
}
