import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class SystemService {
  static Future<void> requestPermissions() async {
    if (kIsWeb) return; // Browsers manage permissions themselves

    await [
      Permission.camera,
      Permission.microphone,
      Permission.phone,
      Permission.storage,
      Permission.notification,
    ].request();
  }

  static Future<bool> checkPermission(Permission permission) async {
    return await permission.isGranted;
  }

  // Background services check simulation
  static Future<bool> isBackgroundServiceRunning() async {
    // In a real app, you might use flutter_background_service to check status.
    // For this educational project, we simulate the health check.
    return true; 
  }
}
