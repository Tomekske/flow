import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceTypeHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Returns true if the device is a Wear OS watch
  static Future<bool> isWearOS() async {
    // If it's not Android, it's definitely not Wear OS (for now)
    if (!Platform.isAndroid) {
      return false;
    }

    // Get detailed Android info
    final androidInfo = await _deviceInfo.androidInfo;

    // Check for specific Wear OS system features
    // 'android.hardware.type.watch' is the standard flag for watches
    // 'android.software.watch' is the newer software flag
    final hasWatchFeature =
        androidInfo.systemFeatures.contains('android.hardware.type.watch') ||
        androidInfo.systemFeatures.contains('android.software.watch');

    return hasWatchFeature;
  }
}
