import 'bytedance_platform_interface.dart';

class Bytedance {
  Future<String?> getPlatformVersion() {
    return BytedancePlatform.instance.getPlatformVersion();
  }

  void uploadRegister(Map<String, dynamic> arguments) {
    BytedancePlatform.instance.uploadRegister(arguments);
  }
}
