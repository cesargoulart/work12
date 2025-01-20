import 'dart:io';
import 'package:flutter/foundation.dart';

class EnvironmentChecker {
  static String getEnvironment() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return 'mobile';
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'desktop';
    } else {
      return 'unknown';
    }
  }
}
