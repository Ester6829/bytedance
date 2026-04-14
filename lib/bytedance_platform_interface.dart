import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bytedance_method_channel.dart';

abstract class BytedancePlatform extends PlatformInterface {
  /// Constructs a BytedancePlatform.
  BytedancePlatform() : super(token: _token);

  static final Object _token = Object();

  static BytedancePlatform _instance = MethodChannelBytedance();

  /// The default instance of [BytedancePlatform] to use.
  ///
  /// Defaults to [MethodChannelBytedance].
  static BytedancePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BytedancePlatform] when
  /// they register themselves.
  static set instance(BytedancePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  void uploadRegister(Map<String, dynamic> arguments) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getIdfv() {
    throw UnimplementedError('getIdfv() has not been implemented.');
  }

  Future<String?> getAndroidId() {
    throw UnimplementedError('getAndroidId() has not been implemented.');
  }
}
