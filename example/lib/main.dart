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
  String _cachedAttributionData = 'Unknown';
  String _pendingDeepLink = 'Unknown';
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
        appId: '947537',
        appName: '千千陪玩',
        channel: 'unknown',
        enableAttribution: true,
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

  /// 主动请求归因数据
  Future<void> _requestAttribution() async {
    try {
      _bytedancePlugin.requestAttribution();
      _appendLog('已请求归因数据，请等待回调');
    } catch (e) {
      _appendLog('请求归因数据失败: $e');
    }
  }

  /// 获取缓存的归因数据
  Future<void> _getCachedAttributionData() async {
    try {
      final data = await _bytedancePlugin.getCachedAttributionData();
      setState(() {
        _cachedAttributionData = data.toString();
      });
      _appendLog('缓存归因数据: $_cachedAttributionData');
    } catch (e) {
      _appendLog('获取缓存归因数据失败: $e');
    }
  }

  /// 获取待处理的深度链接
  Future<void> _getPendingDeepLink() async {
    try {
      final data = await _bytedancePlugin.getPendingDeepLink();
      setState(() {
        _pendingDeepLink = data?.toString() ?? '暂无待处理深度链接';
      });
      _appendLog('待处理深度链接: $_pendingDeepLink');
    } catch (e) {
      _appendLog('获取待处理深度链接失败: $e');
    }
  }

  /// 清除待处理的深度链接
  Future<void> _clearPendingDeepLink() async {
    try {
      _bytedancePlugin.clearPendingDeepLink();
      setState(() {
        _pendingDeepLink = '已清除';
      });
      _appendLog('待处理深度链接已清除');
    } catch (e) {
      _appendLog('清除待处理深度链接失败: $e');
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

  /// 上报激活注册事件 (active_register)
  Future<void> _uploadActiveRegister() async {
    try {
      _bytedancePlugin.uploadActiveRegister(
        userId: 'user_123',
        registerType: 'phone',
        channel: 'toutiao',
        extraParams: {'promotion_id': 'promo_001', 'source': 'ad_click'},
      );
      _appendLog('激活注册事件 (active_register) 已上报');
    } catch (e) {
      _appendLog('上报激活注册事件失败: $e');
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

  /// 上报应用激活事件
  Future<void> _trackAppActivate() async {
    try {
      _bytedancePlugin.trackAppActivate(userId: 'user_123');
      _appendLog('应用激活事件已上报');
    } catch (e) {
      _appendLog('上报应用激活事件失败: $e');
    }
  }

  /// 上报应用退出事件
  Future<void> _trackAppDeactivate() async {
    try {
      _bytedancePlugin.trackAppDeactivate();
      _appendLog('应用退出事件已上报');
    } catch (e) {
      _appendLog('上报应用退出事件失败: $e');
    }
  }

  /// 上报页面浏览事件
  Future<void> _trackPageView() async {
    try {
      _bytedancePlugin.trackPageView(
        pageName: '首页',
        pageUrl: '/home',
        referrer: '/splash',
        extraParams: {'source': 'manual_test'},
      );
      _appendLog('页面浏览事件已上报');
    } catch (e) {
      _appendLog('上报页面浏览事件失败: $e');
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('巨量营销融合归因示例'), elevation: 2),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 平台信息卡片
            _buildSectionCard(
              context,
              title: '平台信息',
              children: [
                Text('版本: $_platformVersion'),
                if (Platform.isIOS) ...[
                  const SizedBox(height: 4),
                  Text('IDFV: $_idfv'),
                  const SizedBox(height: 4),
                  Text('IDFA: $_idfa'),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // 初始化相关
            _buildSectionCard(
              context,
              title: 'SDK 初始化',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _initBytedanceSdk,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('初始化 SDK'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _setDebugMode(true),
                      icon: const Icon(Icons.bug_report),
                      label: const Text('开启调试'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _setDebugMode(false),
                      icon: const Icon(Icons.bug_report_outlined),
                      label: const Text('关闭调试'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 融合归因
            _buildSectionCard(
              context,
              title: '融合归因',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (Platform.isIOS)
                      ElevatedButton.icon(
                        onPressed: _getIdfa,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('获取 IDFA'),
                      ),
                    ElevatedButton.icon(
                      onPressed: _getAttributionData,
                      icon: const Icon(Icons.data_object),
                      label: const Text('获取归因数据'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _requestAttribution,
                      icon: const Icon(Icons.refresh),
                      label: const Text('请求归因'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _getCachedAttributionData,
                      icon: const Icon(Icons.storage),
                      label: const Text('缓存归因'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _getPendingDeepLink,
                      icon: const Icon(Icons.link),
                      label: const Text('待处理链接'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _clearPendingDeepLink,
                      icon: const Icon(Icons.link_off),
                      label: const Text('清除链接'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 用户相关
            _buildSectionCard(
              context,
              title: '用户管理',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _setUserId,
                      icon: const Icon(Icons.person),
                      label: const Text('设置用户 ID'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _clearUserId,
                      icon: const Icon(Icons.person_off),
                      label: const Text('清除用户 ID'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 标准事件上报
            _buildSectionCard(
              context,
              title: '标准事件',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _uploadRegister,
                      icon: const Icon(Icons.app_registration),
                      label: const Text('注册事件'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _uploadActiveRegister,
                      icon: const Icon(Icons.how_to_reg),
                      label: const Text('激活注册'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _uploadLogin,
                      icon: const Icon(Icons.login),
                      label: const Text('登录事件'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _uploadPurchase,
                      icon: const Icon(Icons.payment),
                      label: const Text('购买事件'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 应用生命周期事件
            _buildSectionCard(
              context,
              title: '应用生命周期',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _trackAppActivate,
                      icon: const Icon(Icons.play_circle),
                      label: const Text('应用激活'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _trackAppDeactivate,
                      icon: const Icon(Icons.pause_circle),
                      label: const Text('应用退出'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _trackPageView,
                      icon: const Icon(Icons.remove_red_eye),
                      label: const Text('页面浏览'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 自定义事件
            _buildSectionCard(
              context,
              title: '自定义事件',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _uploadCustomEvent,
                      icon: const Icon(Icons.event),
                      label: const Text('自定义事件'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _trackEvent,
                      icon: const Icon(Icons.track_changes),
                      label: const Text('通用 trackEvent'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 日志区域
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.terminal,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '操作日志',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _clearLog,
                          icon: const Icon(Icons.clear),
                          label: const Text('清空'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        reverse: true,
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _log.isEmpty ? '暂无日志...' : _log,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: _log.isEmpty
                                ? Theme.of(context).colorScheme.outline
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
