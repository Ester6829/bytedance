library bytedance;

import 'bytedance_platform_interface.dart';

class Bytedance {
  static final Bytedance _instance = Bytedance._internal();

  factory Bytedance() => _instance;

  Bytedance._internal();

  void initSdk() {
    BytedancePlatform.instance.initSdk();
  }

  Future<String?> getId() {
    return BytedancePlatform.instance.getId();
  }
}
