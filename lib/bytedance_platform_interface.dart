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

  void initSdk() {
    throw UnimplementedError('initSdk() has not been implemented.');
  }

  Future<String?> getId() {
    throw UnimplementedError('getId() has not been implemented.');
  }
}
