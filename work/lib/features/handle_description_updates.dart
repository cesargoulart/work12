import 'dart:async';

class DescriptionUpdateHandler {
  static final DescriptionUpdateHandler _instance = DescriptionUpdateHandler._internal();
  factory DescriptionUpdateHandler() => _instance;
  DescriptionUpdateHandler._internal();

  String _currentDescription = 'No description';
  final _controller = StreamController<String>.broadcast();

  Stream<String> get descriptionStream => _controller.stream;

  void updateDescription(String newDescription) {
    _currentDescription = newDescription;
    _controller.add(newDescription);
  }

  String getCurrentDescription() => _currentDescription;

  void dispose() {
    _controller.close();
  }
}
