import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:bytedance/bytedance.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _idfv = 'Unknown';
  String _idfa = 'Unknown';
  String _attributionData = 'Unknown';
  String _log = '';
  final _bytedancePlugin = Bytedance();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void _appendLog(String message) {
    setState(() {
      _log = '$_log\n[${DateTime.now().toString().substring(11, 19)}] $message';
    });
    print(message);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _bytedancePlugin.getPlatformVersion() ?? 'Unknown platform version';

      // 初始化 SDK（用于融合归因）- 两个平台都初始化
      await _initBytedanceSdk();

      // 获取 IDFV
      if (Platform.isIOS) {
        final idfv = await _bytedancePlugin.getIdfv();
        setState(() {
          _idfv = idfv ?? 'Failed to get IDFV';
        });
        _appendLog('IDFV: $_idfv');
      }

      // 获取 Android ID
      if (Platform.isAndroid) {
        final androidId = await _bytedancePlugin.getAndroidId();
        _appendLog('Android ID: $androidId');
      }
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  /// 初始化巨量营销 SDK
  Future<void> _initBytedanceSdk() async {
    try {
      _bytedancePlugin.initSdk(
        userId: 'example_user_001',
        enableIdfa: true,
        isDebug: true,
      );
      _appendLog('巨量营销 SDK 初始化成功');
    } catch (e) {
      _appendLog('SDK 初始化失败: $e');
    }
  }

  /// 获取 IDFA
  Future<void> _getIdfa() async {
    if (!Platform.isIOS) {
      _appendLog('IDFA 仅在 iOS 平台可用');
      return;
    }
    try {
      final idfa = await _bytedancePlugin.getIdfa();
      setState(() {
        _idfa = idfa ?? 'Failed to get IDFA';
      });
      _appendLog('IDFA: $_idfa');
    } catch (e) {
      _appendLog('获取 IDFA 失败: $e');
    }
  }

  /// 获取归因数据
  Future<void> _getAttributionData() async {
    try {
      final data = await _bytedancePlugin.getAttributionData();
      setState(() {
        _attributionData = data.toString();
      });
      _appendLog('归因数据: $_attributionData');
    } catch (e) {
      _appendLog('获取归因数据失败: $e');
    }
  }

  /// 设置调试模式
  Future<void> _setDebugMode(bool enabled) async {
    try {
      _bytedancePlugin.setDebugMode(enabled);
      _appendLog("调试模式已${enabled ? '开启' : '关闭'}");
    } catch (e) {
      _appendLog('设置调试模式失败: $e');
    }
  }

  /// 上报注册事件
  Future<void> _uploadRegister() async {
    try {
      _bytedancePlugin.uploadRegister({'userId': 'user_123', 'nickName': '测试用户'});
      _appendLog('注册事件已上报');
    } catch (e) {
      _appendLog('上报注册事件失败: $e');
    }
  }

  /// 上报登录事件
  Future<void> _uploadLogin() async {
    try {
      _bytedancePlugin.uploadLogin(userId: 'user_123', method: 'sms');
      _appendLog('登录事件已上报');
    } catch (e) {
      _appendLog('上报登录事件失败: $e');
    }
  }

  /// 上报购买事件
  Future<void> _uploadPurchase() async {
    try {
      _bytedancePlugin.uploadPurchase(
        orderId: 'order_001',
        amount: 99.99,
        currency: 'CNY',
        productId: 'product_123',
        productName: '高级会员',
        quantity: 1,
      );
      _appendLog('购买事件已上报');
    } catch (e) {
      _appendLog('上报购买事件失败: $e');
    }
  }

  /// 上报自定义事件
  Future<void> _uploadCustomEvent() async {
    try {
      _bytedancePlugin.uploadCustomEvent(
        eventName: 'view_content',
        params: {'content_type': 'product', 'content_id': '123', 'content_name': '示例商品'},
      );
      _appendLog('自定义事件已上报');
    } catch (e) {
      _appendLog('上报自定义事件失败: $e');
    }
  }

  /// 使用通用 trackEvent 方法上报事件
  Future<void> _trackEvent() async {
    try {
      _bytedancePlugin.trackEvent(
        eventName: 'add_to_cart',
        params: {
          'product_id': '456',
          'product_name': '购物车商品',
          'quantity': 2,
          'price': 50.0,
        },
      );
      _appendLog('通用事件已上报');
    } catch (e) {
      _appendLog('上报通用事件失败: $e');
    }
  }

  /// 设置用户 ID
  Future<void> _setUserId() async {
    try {
      _bytedancePlugin.setUserId('new_user_456');
      _appendLog('用户 ID 已设置');
    } catch (e) {
      _appendLog('设置用户 ID 失败: $e');
    }
  }

  /// 清除用户 ID
  Future<void> _clearUserId() async {
    try {
      _bytedancePlugin.clearUserId();
      _appendLog('用户 ID 已清除');
    } catch (e) {
      _appendLog('清除用户 ID 失败: $e');
    }
  }

  /// 清空日志
  void _clearLog() {
    setState(() {
      _log = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('巨量营销融合归因示例')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 平台信息卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('平台信息', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('版本: $_platformVersion'),
                      if (Platform.isIOS) ...[Text('IDFV: $_idfv'), Text('IDFA: $_idfa')],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 初始化相关
              const Text('SDK 初始化', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _initBytedanceSdk,
                    child: const Text('初始化 SDK'),
                  ),
                  ElevatedButton(
                    onPressed: () => _setDebugMode(true),
                    child: const Text('开启调试'),
                  ),
                  ElevatedButton(
                    onPressed: () => _setDebugMode(false),
                    child: const Text('关闭调试'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 归因数据
              const Text('归因数据', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (Platform.isIOS)
                    ElevatedButton(onPressed: _getIdfa, child: const Text('获取 IDFA')),
                  ElevatedButton(
                    onPressed: _getAttributionData,
                    child: const Text('获取归因数据'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 用户相关
              const Text('用户管理', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(onPressed: _setUserId, child: const Text('设置用户 ID')),
                  ElevatedButton(onPressed: _clearUserId, child: const Text('清除用户 ID')),
                ],
              ),

              const SizedBox(height: 16),

              // 事件上报
              const Text('事件上报', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(onPressed: _uploadRegister, child: const Text('注册事件')),
                  ElevatedButton(onPressed: _uploadLogin, child: const Text('登录事件')),
                  ElevatedButton(onPressed: _uploadPurchase, child: const Text('购买事件')),
                  ElevatedButton(
                    onPressed: _uploadCustomEvent,
                    child: const Text('自定义事件'),
                  ),
                  ElevatedButton(
                    onPressed: _trackEvent,
                    child: const Text('通用 trackEvent'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 日志区域
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('操作日志', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(onPressed: _clearLog, child: const Text('清空')),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _log.isEmpty ? '暂无日志...' : _log,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
