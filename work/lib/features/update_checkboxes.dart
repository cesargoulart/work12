import '../models/project_model.dart';

void updateCheckboxes(List<CheckboxModel> checkboxes) {
  // Implement the logic to update the checkboxes in your app
  for (var checkbox in checkboxes) {
    print('Checkbox ${checkbox.label} is ${checkbox.value ? 'checked' : 'unchecked'}');
  }
}
