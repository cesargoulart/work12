import 'package:flutter/material.dart';
import '../models/project_model.dart';

typedef CheckboxStateUpdater = void Function(Map<String, bool> newValues);
late CheckboxStateUpdater _updateCheckboxState;

void initCheckboxUpdater(CheckboxStateUpdater updater) {
  _updateCheckboxState = updater;
}

void updateCheckboxes(List<CheckboxModel> checkboxes) {
  final Map<String, bool> newValues = {};
  for (var checkbox in checkboxes) {
    newValues[checkbox.label] = checkbox.value;
  }
  _updateCheckboxState(newValues);
}
