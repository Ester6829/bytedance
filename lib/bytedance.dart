import 'bytedance_platform_interface.dart';

class Bytedance {
  Future<String?> getPlatformVersion() {
    return BytedancePlatform.instance.getPlatformVersion();
  }

  void uploadRegister(Map<String, dynamic> arguments) {
    BytedancePlatform.instance.uploadRegister(arguments);
  }

  Future<String?> getIdfv() {
    return BytedancePlatform.instance.getIdfv();
  }

  Future<String?> getAndroidId() {
    return BytedancePlatform.instance.getAndroidId();
  }
}
