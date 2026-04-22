import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bytedance_platform_interface.dart';

/// An implementation of [BytedancePlatform] that uses method channels.
class MethodChannelBytedance extends BytedancePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bytedance');

  @override
  void initSdk() {
    methodChannel.invokeMethod('initSdk');
  }

  @override
  Future<String?> getId() async {
    final id = await methodChannel.invokeMethod<String>('getId');
    return id;
  }
}
