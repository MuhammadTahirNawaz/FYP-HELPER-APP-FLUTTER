import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/app_logger.dart';
import '../core/supported_platform.dart';

/// Summary of runtime permission checks shown at startup (for viva / debugging).
class PermissionStartupResult {
  const PermissionStartupResult({
    required this.skipped,
    required this.granted,
    required this.denied,
    required this.permanentlyDenied,
  });

  final bool skipped;
  final List<String> granted;
  final List<String> denied;
  final List<String> permanentlyDenied;

  factory PermissionStartupResult.skipped() => const PermissionStartupResult(
        skipped: true,
        granted: [],
        denied: [],
        permanentlyDenied: [],
      );

  String get summary {
    if (skipped) {
      return 'Permission checks skipped (non-Android platform).';
    }
    return 'Granted: ${granted.join(', ')}'
        '${denied.isNotEmpty ? ' | Denied: ${denied.join(', ')}' : ''}'
        '${permanentlyDenied.isNotEmpty ? ' | Blocked: ${permanentlyDenied.join(', ')}' : ''}';
  }
}

class SystemService {
  SystemService._();

  /// Permissions required for document uploads, camera capture, and in-app alerts.
  static List<Permission> get _startupPermissions => [
        Permission.camera,
        Permission.photos,
        Permission.videos,
        Permission.notification,
        Permission.storage,
      ];

  /// Request standard runtime permissions during splash / cold start.
  static Future<PermissionStartupResult> requestPermissionsAtStartup() async {
    if (kIsWeb || !SupportedPlatform.isAndroid) {
      AppLogger.debug(
        'Skipping runtime permission prompts on ${SupportedPlatform.name}.',
        tag: 'PERMISSIONS',
      );
      return PermissionStartupResult.skipped();
    }

    AppLogger.debug(
      'Requesting startup permissions…',
      tag: 'PERMISSIONS',
    );

    final granted = <String>[];
    final denied = <String>[];
    final permanentlyDenied = <String>[];

    final statuses = await _startupPermissions.request();

    for (final entry in statuses.entries) {
      final name = entry.key.toString().split('.').last;
      switch (entry.value) {
        case PermissionStatus.granted:
        case PermissionStatus.limited:
          granted.add(name);
        case PermissionStatus.permanentlyDenied:
          permanentlyDenied.add(name);
        case PermissionStatus.denied:
        case PermissionStatus.restricted:
          denied.add(name);
        case PermissionStatus.provisional:
          granted.add(name);
      }
    }

    final result = PermissionStartupResult(
      skipped: false,
      granted: granted,
      denied: denied,
      permanentlyDenied: permanentlyDenied,
    );

    AppLogger.debug(result.summary, tag: 'PERMISSIONS');
    return result;
  }

  /// Legacy alias kept for any existing call sites.
  static Future<void> requestPermissions() async {
    await requestPermissionsAtStartup();
  }

  static Future<bool> checkPermission(Permission permission) async {
    if (kIsWeb || !SupportedPlatform.isAndroid) {
      return true;
    }
    final status = await permission.status;
    return status.isGranted || status.isLimited;
  }

  /// Returns `true` when every permission needed for file upload is granted.
  static Future<bool> hasUploadPermissions() async {
    if (kIsWeb || !SupportedPlatform.isAndroid) {
      return true;
    }

    final camera = await Permission.camera.status;
    final photos = await Permission.photos.status;
    final videos = await Permission.videos.status;
    final storage = await Permission.storage.status;

    return camera.isGranted ||
        photos.isGranted ||
        photos.isLimited ||
        videos.isGranted ||
        videos.isLimited ||
        storage.isGranted;
  }

  /// Opens system settings when the user has permanently denied a permission.
  static Future<bool> openAppSettingsPage() => openAppSettings();

  // Background services check simulation
  static Future<bool> isBackgroundServiceRunning() async {
    // In a real app, you might use flutter_background_service to check status.
    // For this educational project, we simulate the health check.
    return true;
  }
}
