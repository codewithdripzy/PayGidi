import 'dart:io' show Platform;

class DeviceInfo {
  final String deviceName;
  final String deviceType;
  final String deviceOs;

  DeviceInfo({
    required this.deviceName,
    required this.deviceType,
    required this.deviceOs,
  });

  Map<String, dynamic> toJson() => {
    'deviceName': deviceName,
    'deviceType': deviceType,
    'deviceOs': deviceOs,
  };

  static DeviceInfo get current {
    String os = '';
    String type = '';
    String name = '';

    try {
      os = Platform.operatingSystemVersion;
      name = Platform.localHostname;

      if (Platform.isAndroid) {
        type = 'mobile';
        if (os.isEmpty) os = 'Android';
      } else if (Platform.isIOS) {
        type = 'mobile';
        if (os.isEmpty) os = 'iOS';
      } else if (Platform.isMacOS) {
        type = 'desktop';
        if (os.isEmpty) os = 'macOS';
      } else if (Platform.isWindows) {
        type = 'desktop';
        if (os.isEmpty) os = 'Windows';
      } else if (Platform.isLinux) {
        type = 'desktop';
        if (os.isEmpty) os = 'Linux';
      } else {
        type = 'mobile';
        os = 'Unknown';
      }
    } catch (_) {
      type = 'mobile';
      os = 'Unknown';
      name = 'Unknown Device';
    }

    return DeviceInfo(deviceName: name, deviceType: type, deviceOs: os);
  }
}
