import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';

class DeviceInfoApi {
  static final _deviceInfoPlugin = DeviceInfoPlugin();

  static Future<String> getOperatingSystem() async => Platform.operatingSystem;

  static Future<String> getScreenResolution() async =>
      '${window.physicalSize.width} X ${window.physicalSize.height}';

  static Future<String> getPhoneInfo() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfoPlugin.androidInfo;

      return '${info.manufacturer} - ${info.model}';
    } else if (Platform.isIOS) {
      final info = await _deviceInfoPlugin.iosInfo;

      return '${info.name} ${info.model}';
    } else {
      throw UnimplementedError();
    }
  }

  static Future<String> getPhoneVersion() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfoPlugin.androidInfo;
      return info.version.sdkInt.toString();
    } else if (Platform.isIOS) {
      final info = await _deviceInfoPlugin.iosInfo;
      return info.systemVersion;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getInfo() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfoPlugin.androidInfo;
        return _readAndroidBuildData(info);
      } else if (Platform.isIOS) {
        final info = await _deviceInfoPlugin.iosInfo;
        return _readIosDeviceInfo(info);
      } else {
        throw UnimplementedError();
      }
    } on PlatformException {
      return <String, dynamic>{'Error:': 'Failed to get platform version.'};
    }
  }

  static Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo info) =>
      <String, dynamic>{
        'device': info.device,
        'brand': info.brand,
        'isPhysicalDevice': info.isPhysicalDevice,
        'version.sdkInt': info.version.sdkInt,
        'manufacturer': info.manufacturer,
        'model': info.model,
        '': '',
        ' ': '',
        'version.securityPatch': info.version.securityPatch,
        'version.release': info.version.release,
        'version.previewSdkInt': info.version.previewSdkInt,
        'version.incremental': info.version.incremental,
        'version.codename': info.version.codename,
        'version.baseOS': info.version.baseOS,
        'board': info.board,
        'bootloader': info.bootloader,
        'display': info.display,
        'fingerprint': info.fingerprint,
        'hardware': info.hardware,
        'host': info.host,
        'id': info.id,
        'product': info.product,
        'supported32BitAbis': info.supported32BitAbis,
        'supported64BitAbis': info.supported64BitAbis,
        'supportedAbis': info.supportedAbis,
        'tags': info.tags,
        'type': info.type,
        'androidId': info.androidId,
        'systemFeatures': info.systemFeatures,
      };

  static Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo info) =>
      <String, dynamic>{
        'name': info.name,
        'systemName': info.systemName,
        'systemVersion': info.systemVersion,
        'model': info.model,
        'localizedModel': info.localizedModel,
        'identifierForVendor': info.identifierForVendor,
        'isPhysicalDevice': info.isPhysicalDevice,
        'utsname.sysname:': info.utsname.sysname,
        'utsname.nodename:': info.utsname.nodename,
        'utsname.release:': info.utsname.release,
        'utsname.version:': info.utsname.version,
        'utsname.machine:': info.utsname.machine,
      };
}
