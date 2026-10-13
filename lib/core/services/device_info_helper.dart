import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Structured metadata describing the host device, OS, and app version
class AppDeviceDetails {
  final String deviceModel;
  final String deviceBrand;
  final String deviceManufacturer;
  final String osVersion;
  final int osSdkInt;
  final String appVersion;
  final String buildNumber;
  final String platform;

  const AppDeviceDetails({
    required this.deviceModel,
    required this.deviceBrand,
    required this.deviceManufacturer,
    required this.osVersion,
    required this.osSdkInt,
    required this.appVersion,
    required this.buildNumber,
    required this.platform,
  });

  String get fullAppVersion => '$appVersion+$buildNumber';

  Map<String, dynamic> toMap() {
    return {
      'deviceModel': deviceModel,
      'deviceBrand': deviceBrand,
      'deviceManufacturer': deviceManufacturer,
      'osVersion': osVersion,
      'osSdkInt': osSdkInt,
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'fullAppVersion': fullAppVersion,
      'platform': platform,
    };
  }

  static const AppDeviceDetails fallback = AppDeviceDetails(
    deviceModel: 'Android Device',
    deviceBrand: 'Android',
    deviceManufacturer: 'Unknown',
    osVersion: 'Android OS',
    osSdkInt: 0,
    appVersion: '1.0.0',
    buildNumber: '11',
    platform: 'Android',
  );
}

/// Helper service to extract device, OS, and app version information
class DeviceInfoHelper {
  DeviceInfoHelper._();

  static AppDeviceDetails? _cachedDetails;

  /// Fetches device, OS, and app metadata with graceful fallbacks
  static Future<AppDeviceDetails> getDeviceDetails() async {
    if (_cachedDetails != null) return _cachedDetails!;

    String deviceModel = 'Unknown Device';
    String deviceBrand = 'Unknown';
    String deviceManufacturer = 'Unknown';
    String osVersion = kIsWeb ? 'Web' : Platform.operatingSystemVersion;
    int osSdkInt = 0;
    String appVersion = '1.0.0';
    String buildNumber = '11';
    final platform = kIsWeb
        ? 'Web'
        : (Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : Platform.operatingSystem));

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    } catch (e) {
      debugPrint('[DeviceInfoHelper] PackageInfo error: $e');
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (!kIsWeb && Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceModel = androidInfo.model;
        deviceBrand = androidInfo.brand;
        deviceManufacturer = androidInfo.manufacturer;
        osVersion = 'Android ${androidInfo.version.release} (API ${androidInfo.version.sdkInt})';
        osSdkInt = androidInfo.version.sdkInt;
      } else if (!kIsWeb && Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceModel = iosInfo.utsname.machine;
        deviceBrand = 'Apple';
        deviceManufacturer = 'Apple';
        osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
      }
    } catch (e) {
      debugPrint('[DeviceInfoHelper] DeviceInfoPlugin error: $e');
    }

    _cachedDetails = AppDeviceDetails(
      deviceModel: deviceModel,
      deviceBrand: deviceBrand,
      deviceManufacturer: deviceManufacturer,
      osVersion: osVersion,
      osSdkInt: osSdkInt,
      appVersion: appVersion,
      buildNumber: buildNumber,
      platform: platform,
    );

    return _cachedDetails!;
  }
}
