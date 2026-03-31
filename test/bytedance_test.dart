import 'package:flutter_test/flutter_test.dart';
import 'package:bytedance/bytedance.dart';
import 'package:bytedance/bytedance_platform_interface.dart';
import 'package:bytedance/bytedance_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBytedancePlatform
    with MockPlatformInterfaceMixin
    implements BytedancePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BytedancePlatform initialPlatform = BytedancePlatform.instance;

  test('$MethodChannelBytedance is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBytedance>());
  });

  test('getPlatformVersion', () async {
    Bytedance bytedancePlugin = Bytedance();
    MockBytedancePlatform fakePlatform = MockBytedancePlatform();
    BytedancePlatform.instance = fakePlatform;

    expect(await bytedancePlugin.getPlatformVersion(), '42');
  });
}
