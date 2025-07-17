import 'package:flutter/foundation.dart';
// import 'package:home_widget/home_widget.dart';
// import 'package:workmanager/workmanager.dart';

class WidgetManager {
  static Future<void> initializeWidgets() async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux) {
      return; // Skip widget initialization on non-mobile platforms
    }
    
    // Widget functionality disabled - packages commented out
    debugPrint('Widget functionality disabled');
  }
  
  static Future<void> updateAllWidgets() async {
    // Widget functionality disabled
    debugPrint('Widget update skipped - packages disabled');
  }
}