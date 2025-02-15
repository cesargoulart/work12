class Project {
  final String description;
  final List<CheckboxModel> checkboxes;

  Project({required this.description, required this.checkboxes});
}

class CheckboxModel {
  final String label;
  final bool value;

  CheckboxModel({required this.label, required this.value});
}
