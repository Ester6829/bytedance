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

  @override
  void uploadLogin(Map<String, dynamic> arguments) {
    methodChannel.invokeMethod('uploadLogin', arguments);
  }

  @override
  void uploadPurchase(Map<String, dynamic> arguments) {
    methodChannel.invokeMethod('uploadPurchase', arguments);
  }

  @override
  void uploadCustomEvent(Map<String, dynamic> arguments) {
    methodChannel.invokeMethod('uploadCustomEvent', arguments);
  }

  @override
  void setUserId(Map<String, dynamic> arguments) {
    methodChannel.invokeMethod('setUserId', arguments);
  }

  @override
  void clearUserId() {
    methodChannel.invokeMethod('clearUserId');
  }

  @override
  Future<String?> getIdfa() async {
    final idfa = await methodChannel.invokeMethod<String>('getIdfa');
    return idfa;
  }

  @override
  void initSdk(Map<String, dynamic> arguments) {
    methodChannel.invokeMethod('initSdk', arguments);
  }

  @override
  void trackEvent(Map<String, dynamic> arguments) {
    methodChannel.invokeMethod('trackEvent', arguments);
  }

  @override
  void setDebugMode(Map<String, dynamic> arguments) {
    methodChannel.invokeMethod('setDebugMode', arguments);
  }

  @override
  Future<Map<String, dynamic>?> getAttributionData() async {
    final data = await methodChannel.invokeMethod<Map<Object?, Object?>>('getAttributionData');
    return data?.cast<String, dynamic>();
  }

  @override
  void uploadActiveRegister(Map<String, dynamic> arguments) {
    methodChannel.invokeMethod('uploadActiveRegister', arguments);
  }

  @override
  void requestAttribution() {
    methodChannel.invokeMethod('requestAttribution');
  }

  @override
  Future<Map<String, dynamic>?> getCachedAttributionData() async {
    final data = await methodChannel.invokeMethod<Map<Object?, Object?>>('getCachedAttributionData');
    return data?.cast<String, dynamic>();
  }

  @override
  Future<Map<String, dynamic>?> getPendingDeepLink() async {
    final data = await methodChannel.invokeMethod<Map<Object?, Object?>>('getPendingDeepLink');
    return data?.cast<String, dynamic>();
  }

  @override
  void clearPendingDeepLink() {
    methodChannel.invokeMethod('clearPendingDeepLink');
  }

  @override
  void trackAppActivate(Map<String, dynamic> arguments) {
    methodChannel.invokeMethod('trackAppActivate', arguments);
  }

  @override
  void trackAppDeactivate() {
    methodChannel.invokeMethod('trackAppDeactivate');
  }

  @override
  void trackPageView(Map<String, dynamic> arguments) {
    methodChannel.invokeMethod('trackPageView', arguments);
  }
}
