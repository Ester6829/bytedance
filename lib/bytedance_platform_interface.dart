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
    throw UnimplementedError('uploadRegister() has not been implemented.');
  }

  Future<String?> getIdfv() {
    throw UnimplementedError('getIdfv() has not been implemented.');
  }

  Future<String?> getAndroidId() {
    throw UnimplementedError('getAndroidId() has not been implemented.');
  }

  void uploadLogin(Map<String, dynamic> arguments) {
    throw UnimplementedError('uploadLogin() has not been implemented.');
  }

  void uploadPurchase(Map<String, dynamic> arguments) {
    throw UnimplementedError('uploadPurchase() has not been implemented.');
  }

  void uploadCustomEvent(Map<String, dynamic> arguments) {
    throw UnimplementedError('uploadCustomEvent() has not been implemented.');
  }

  void setUserId(Map<String, dynamic> arguments) {
    throw UnimplementedError('setUserId() has not been implemented.');
  }

  void clearUserId() {
    throw UnimplementedError('clearUserId() has not been implemented.');
  }

  Future<String?> getIdfa() {
    throw UnimplementedError('getIdfa() has not been implemented.');
  }

  void initSdk(Map<String, dynamic> arguments) {
    throw UnimplementedError('initSdk() has not been implemented.');
  }

  void trackEvent(Map<String, dynamic> arguments) {
    throw UnimplementedError('trackEvent() has not been implemented.');
  }

  void setDebugMode(Map<String, dynamic> arguments) {
    throw UnimplementedError('setDebugMode() has not been implemented.');
  }

  Future<Map<String, dynamic>?> getAttributionData() {
    throw UnimplementedError('getAttributionData() has not been implemented.');
  }

  void uploadActiveRegister(Map<String, dynamic> arguments) {
    throw UnimplementedError('uploadActiveRegister() has not been implemented.');
  }

  void requestAttribution() {
    throw UnimplementedError('requestAttribution() has not been implemented.');
  }

  Future<Map<String, dynamic>?> getCachedAttributionData() {
    throw UnimplementedError('getCachedAttributionData() has not been implemented.');
  }

  Future<Map<String, dynamic>?> getPendingDeepLink() {
    throw UnimplementedError('getPendingDeepLink() has not been implemented.');
  }

  void clearPendingDeepLink() {
    throw UnimplementedError('clearPendingDeepLink() has not been implemented.');
  }

  void trackAppActivate(Map<String, dynamic> arguments) {
    throw UnimplementedError('trackAppActivate() has not been implemented.');
  }

  void trackAppDeactivate() {
    throw UnimplementedError('trackAppDeactivate() has not been implemented.');
  }

  void trackPageView(Map<String, dynamic> arguments) {
    throw UnimplementedError('trackPageView() has not been implemented.');
  }
}
