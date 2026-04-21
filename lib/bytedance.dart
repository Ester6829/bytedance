/// 巨量营销融合归因 Flutter 插件
///
/// 提供巨量引擎广告平台的事件追踪、归因分析等功能
///
/// 主要功能：
/// - 设备标识获取（IDFA、IDFV、Android ID）
/// - 标准化事件上报（注册、登录、购买等）
/// - 自定义事件追踪
/// - 融合归因数据获取
/// - 深度链接处理
///
/// 使用前请先调用 [initSdk] 初始化 SDK
library bytedance;

import 'bytedance_platform_interface.dart';

/// 巨量营销插件主类
///
/// 提供所有巨量营销融合归因功能的入口点
///
/// 示例：
/// ```dart
/// final bytedance = Bytedance();
///
/// // 初始化 SDK
/// await bytedance.initSdk(
///   appId: 'your_app_id',
///   isDebug: true,
/// );
///
/// // 上报事件
/// bytedance.uploadActiveRegister(
///   userId: 'user_123',
///   registerType: 'phone',
/// );
/// ```
class Bytedance {
  /// 单例实例
  static final Bytedance _instance = Bytedance._internal();

  /// 获取单例实例
  factory Bytedance() => _instance;

  Bytedance._internal();

  // ==========================================
  // 常量定义
  // ==========================================

  /// 事件名称常量
  static const String eventRegister = 'register';
  static const String eventActiveRegister = 'active_register';
  static const String eventLogin = 'login';
  static const String eventPurchase = 'purchase';
  static const String eventAppActivate = 'app_activate';
  static const String eventAppDeactivate = 'app_deactivate';
  static const String eventPageView = 'page_view';

  /// 注册方式常量
  static const String registerTypePhone = 'phone';
  static const String registerTypeWechat = 'wechat';
  static const String registerTypeQQ = 'qq';
  static const String registerTypeSms = 'sms';
  static const String registerTypePassword = 'password';

  /// 渠道常量
  static const String channelToutiao = 'toutiao';
  static const String channelDouyin = 'douyin';
  static const String channelXigua = 'xigua';
  static const String channelAppStore = 'App Store';
  static const String channelGooglePlay = 'Google Play';

  // ==========================================
  // 基础信息获取
  // ==========================================

  /// 获取平台版本信息
  ///
  /// 返回当前操作系统版本，如 "iOS 17.0" 或 "Android 13"
  Future<String?> getPlatformVersion() {
    return BytedancePlatform.instance.getPlatformVersion();
  }

  /// 获取 IDFV (Identifier for Vendor)
  ///
  /// iOS 平台专用，同一开发商的应用共享同一 IDFV
  /// Android 平台返回 null
  Future<String?> getIdfv() {
    return BytedancePlatform.instance.getIdfv();
  }

  /// 获取 IDFA (Identifier for Advertising)
  ///
  /// iOS 平台专用，用于广告追踪
  /// 需要用户授权才能获取
  /// Android 平台返回 null
  Future<String?> getIdfa() {
    return BytedancePlatform.instance.getIdfa();
  }

  /// 获取 Android ID
  ///
  /// Android 平台专用
  /// iOS 平台返回 null
  Future<String?> getAndroidId() {
    return BytedancePlatform.instance.getAndroidId();
  }

  // ==========================================
  // SDK 初始化与配置
  // ==========================================

  /// 初始化巨量营销 SDK
  ///
  /// 必须在使用其他功能前调用此方法
  ///
  /// [appId] 巨量引擎分配的应用 ID
  /// [appName] 应用名称（可选）
  /// [channel] 渠道标识（可选），如 "App Store"、"toutiao" 等
  /// [userId] 用户 ID（可选），如果当前有用户登录可传入
  /// [enableIdfa] 是否启用 IDFA 追踪（iOS 专用），默认 true
  /// [isDebug] 是否开启调试模式，默认 false
  /// [enableAttribution] 是否启用归因功能，默认 true
  /// [enableOaid] 是否启用 OAID 追踪（Android 专用），默认 true
  ///
  /// 示例：
  /// ```dart
  /// bytedance.initSdk(
  ///   appId: 'your_app_id_here',
  ///   appName: '示例应用',
  ///   channel: Bytedance.channelAppStore,
  ///   isDebug: kDebugMode,
  /// );
  /// ```
  void initSdk({
    String? appId,
    String? appName,
    String? channel,
    String? userId,
    bool enableIdfa = true,
    bool isDebug = false,
    bool enableAttribution = true,
    bool enableOaid = true,
  }) {
    BytedancePlatform.instance.initSdk({
      if (appId != null) 'appId': appId,
      if (appName != null) 'appName': appName,
      if (channel != null) 'channel': channel,
      if (userId != null) 'userId': userId,
      'enableIdfa': enableIdfa,
      'isDebug': isDebug,
      'enableAttribution': enableAttribution,
      'enableOaid': enableOaid,
    });
  }

  /// 设置调试模式
  ///
  /// [enable] 是否开启调试日志
  /// 开启后会在控制台输出详细的 SDK 日志
  void setDebugMode(bool enable) {
    BytedancePlatform.instance.setDebugMode({'enable': enable});
  }

  // ==========================================
  // 用户管理
  // ==========================================

  /// 设置用户 ID
  ///
  /// 用于用户关联，在用户登录成功后调用
  /// [userId] 用户的唯一标识符
  void setUserId(String userId) {
    BytedancePlatform.instance.setUserId({'userId': userId});
  }

  /// 清除用户 ID
  ///
  /// 用户退出登录时调用，停止对该用户的追踪
  void clearUserId() {
    BytedancePlatform.instance.clearUserId();
  }

  // ==========================================
  // 标准事件上报
  // ==========================================

  /// 上报注册事件
  ///
  /// 使用命名参数版本，请使用 [uploadRegisterWithParams] 或 [uploadActiveRegister]
  void uploadRegister(Map<String, dynamic> arguments) {
    BytedancePlatform.instance.uploadRegister(arguments);
  }

  /// 上报注册事件
  ///
  /// [userId] 用户 ID
  /// [nickName] 用户昵称
  /// [registerType] 注册方式，使用 [registerTypePhone] 等常量
  /// [channel] 渠道来源
  void uploadRegisterWithParams({
    String? userId,
    String? nickName,
    String? registerType,
    String? channel,
  }) {
    BytedancePlatform.instance.uploadRegister({
      if (userId != null) 'userId': userId,
      if (nickName != null) 'nickName': nickName,
      if (registerType != null) 'registerType': registerType,
      if (channel != null) 'channel': channel,
    });
  }

  /// 上报激活注册事件
  ///
  /// 用户在推广的应用/落地页场景下完成注册（手机号/微信等）行为
  /// 这是巨量营销融合归因的核心事件
  ///
  /// [userId] 用户 ID
  /// [registerType] 注册方式，如 "phone"、"wechat" 等
  /// [channel] 渠道来源，如 "toutiao"、"douyin" 等
  /// [extraParams] 额外的自定义参数
  ///
  /// 示例：
  /// ```dart
  /// bytedance.uploadActiveRegister(
  ///   userId: 'user_123',
  ///   registerType: Bytedance.registerTypePhone,
  ///   channel: Bytedance.channelToutiao,
  ///   extraParams: {
  ///     'promotion_id': 'promo_001',
  ///     'invite_code': 'ABC123',
  ///   },
  /// );
  /// ```
  void uploadActiveRegister({
    String? userId,
    String? registerType,
    String? channel,
    Map<String, dynamic>? extraParams,
  }) {
    BytedancePlatform.instance.uploadActiveRegister({
      if (userId != null) 'userId': userId,
      if (registerType != null) 'registerType': registerType,
      if (channel != null) 'channel': channel,
      if (extraParams != null) 'extraParams': extraParams,
    });
  }

  /// 上报登录事件
  ///
  /// [userId] 用户 ID
  /// [method] 登录方式，如 "password"、"sms"、"wechat" 等
  void uploadLogin({String? userId, String? method}) {
    BytedancePlatform.instance.uploadLogin({
      if (userId != null) 'userId': userId,
      if (method != null) 'method': method,
    });
  }

  /// 上报购买事件
  ///
  /// [orderId] 订单 ID
  /// [amount] 金额，单位为元
  /// [currency] 货币类型，默认 CNY
  /// [productId] 商品 ID
  /// [productName] 商品名称
  /// [quantity] 数量
  /// [extraParams] 额外参数
  ///
  /// 示例：
  /// ```dart
  /// bytedance.uploadPurchase(
  ///   orderId: 'order_2024_001',
  ///   amount: 99.99,
  ///   currency: 'CNY',
  ///   productId: 'product_123',
  ///   productName: '年度会员',
  ///   quantity: 1,
  /// );
  /// ```
  void uploadPurchase({
    String? orderId,
    double? amount,
    String currency = 'CNY',
    String? productId,
    String? productName,
    int? quantity,
    Map<String, dynamic>? extraParams,
  }) {
    final params = <String, dynamic>{
      'currency': currency,
      if (orderId != null) 'orderId': orderId,
      if (amount != null) 'amount': amount,
      if (productId != null) 'productId': productId,
      if (productName != null) 'productName': productName,
      if (quantity != null) 'quantity': quantity,
      if (extraParams != null) ...extraParams,
    };
    BytedancePlatform.instance.uploadPurchase(params);
  }

  // ==========================================
  // 应用生命周期事件
  // ==========================================

  /// 上报应用激活事件
  ///
  /// 应用启动时调用，标记应用激活
  /// [userId] 用户 ID（可选）
  void trackAppActivate({String? userId}) {
    BytedancePlatform.instance.trackAppActivate({if (userId != null) 'userId': userId});
  }

  /// 上报应用退出事件
  ///
  /// 应用进入后台时调用
  void trackAppDeactivate() {
    BytedancePlatform.instance.trackAppDeactivate();
  }

  /// 上报页面浏览事件
  ///
  /// [pageName] 页面名称
  /// [pageUrl] 页面 URL（可选）
  /// [referrer] 来源页面（可选）
  /// [extraParams] 额外参数
  ///
  /// 示例：
  /// ```dart
  /// bytedance.trackPageView(
  ///   pageName: '商品详情页',
  ///   pageUrl: '/product/123',
  ///   referrer: '/home',
  ///   extraParams: {'product_id': '123'},
  /// );
  /// ```
  void trackPageView({
    String? pageName,
    String? pageUrl,
    String? referrer,
    Map<String, dynamic>? extraParams,
  }) {
    BytedancePlatform.instance.trackPageView({
      if (pageName != null) 'pageName': pageName,
      if (pageUrl != null) 'pageUrl': pageUrl,
      if (referrer != null) 'referrer': referrer,
      if (extraParams != null) 'extraParams': extraParams,
    });
  }

  // ==========================================
  // 自定义事件
  // ==========================================

  /// 上报自定义事件
  ///
  /// [eventName] 事件名称
  /// [params] 事件参数
  ///
  /// 示例：
  /// ```dart
  /// bytedance.uploadCustomEvent(
  ///   eventName: 'view_content',
  ///   params: {
  ///     'content_type': 'product',
  ///     'content_id': '123',
  ///   },
  /// );
  /// ```
  void uploadCustomEvent({required String eventName, Map<String, dynamic>? params}) {
    BytedancePlatform.instance.uploadCustomEvent({
      'eventName': eventName,
      if (params != null) 'params': params,
    });
  }

  /// 通用事件追踪方法（同 uploadCustomEvent）
  ///
  /// [eventName] 事件名称
  /// [params] 事件参数
  void trackEvent({required String eventName, Map<String, dynamic>? params}) {
    BytedancePlatform.instance.trackEvent({
      'eventName': eventName,
      if (params != null) 'params': params,
    });
  }

  // ==========================================
  // 融合归因
  // ==========================================

  /// 获取归因数据
  ///
  /// 返回包含设备信息、归因信息等的 Map
  /// iOS: 包含 idfv, idfa, osVersion
  /// Android: 包含 androidId, osVersion
  Future<Map<String, dynamic>?> getAttributionData() {
    return BytedancePlatform.instance.getAttributionData();
  }

  /// 主动请求归因数据
  ///
  /// 向巨量引擎服务器请求最新的归因数据
  /// 结果通过回调返回，请监听相应的回调事件
  void requestAttribution() {
    BytedancePlatform.instance.requestAttribution();
  }

  /// 获取缓存的归因数据
  ///
  /// 返回本地缓存的归因数据
  /// 包含 campaignId, adgroupId, creativeId, clickId 等信息
  Future<Map<String, dynamic>?> getCachedAttributionData() {
    return BytedancePlatform.instance.getCachedAttributionData();
  }

  // ==========================================
  // 深度链接
  // ==========================================

  /// 获取待处理的深度链接
  ///
  /// 返回通过广告点击唤起应用时携带的深度链接数据
  /// 包含 deepLink 和 params 字段
  Future<Map<String, dynamic>?> getPendingDeepLink() {
    return BytedancePlatform.instance.getPendingDeepLink();
  }

  /// 清除待处理的深度链接
  ///
  /// 处理完深度链接后调用，避免重复处理
  void clearPendingDeepLink() {
    BytedancePlatform.instance.clearPendingDeepLink();
  }
}
