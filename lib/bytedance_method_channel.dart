import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bytedance_platform_interface.dart';

/// An implementation of [BytedancePlatform] that uses method channels.
class MethodChannelBytedance extends BytedancePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bytedance');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  void uploadRegister(Map<String, dynamic> arguments) {
    methodChannel.invokeMethod('uploadRegister', arguments);
  }

  @override
  Future<String?> getIdfv() async {
    final idfv = await methodChannel.invokeMethod<String>('getIdfv');
    return idfv;
  }

  @override
  Future<String?> getAndroidId() async {
    final androidId = await methodChannel.invokeMethod<String>('getAndroidId');
    return androidId;
  }
}
