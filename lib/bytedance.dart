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

  /// 上报登录事件
  /// [userId] 用户ID
  /// [method] 登录方式（如：password, sms, wechat 等）
  void uploadLogin({String? userId, String? method}) {
    BytedancePlatform.instance.uploadLogin({
      if (userId != null) 'userId': userId,
      if (method != null) 'method': method,
    });
  }

  /// 上报购买事件
  /// [orderId] 订单ID
  /// [amount] 金额
  /// [currency] 货币类型，默认 CNY
  /// [productId] 商品ID
  /// [productName] 商品名称
  /// [quantity] 数量
  void uploadPurchase({
    String? orderId,
    double? amount,
    String currency = 'CNY',
    String? productId,
    String? productName,
    int? quantity,
  }) {
    BytedancePlatform.instance.uploadPurchase({
      if (orderId != null) 'orderId': orderId,
      if (amount != null) 'amount': amount,
      'currency': currency,
      if (productId != null) 'productId': productId,
      if (productName != null) 'productName': productName,
      if (quantity != null) 'quantity': quantity,
    });
  }

  /// 上报自定义事件
  /// [eventName] 事件名称
  /// [params] 事件参数
  void uploadCustomEvent({
    required String eventName,
    Map<String, dynamic>? params,
  }) {
    BytedancePlatform.instance.uploadCustomEvent({
      'eventName': eventName,
      if (params != null) 'params': params,
    });
  }

  /// 设置用户ID（用于用户关联）
  /// [userId] 用户ID
  void setUserId(String userId) {
    BytedancePlatform.instance.setUserId({'userId': userId});
  }

  /// 清除用户ID（用户退出登录时调用）
  void clearUserId() {
    BytedancePlatform.instance.clearUserId();
  }

  /// 获取 IDFA (Identifier for Advertising)
  Future<String?> getIdfa() {
    return BytedancePlatform.instance.getIdfa();
  }

  /// 初始化巨量营销 SDK
  /// [userId] 用户ID（可选）
  /// [enableIdfa] 是否启用 IDFA 追踪，默认 true
  /// [isDebug] 是否开启调试模式，默认 false
  void initSdk({
    String? userId,
    bool enableIdfa = true,
    bool isDebug = false,
  }) {
    BytedancePlatform.instance.initSdk({
      if (userId != null) 'userId': userId,
      'enableIdfa': enableIdfa,
      'isDebug': isDebug,
    });
  }

  /// 通用事件追踪方法
  /// [eventName] 事件名称
  /// [params] 事件参数
  void trackEvent({
    required String eventName,
    Map<String, dynamic>? params,
  }) {
    BytedancePlatform.instance.trackEvent({
      'eventName': eventName,
      if (params != null) 'params': params,
    });
  }

  /// 设置调试模式
  /// [enable] 是否开启调试日志
  void setDebugMode(bool enable) {
    BytedancePlatform.instance.setDebugMode({
      'enable': enable,
    });
  }

  /// 获取归因数据
  /// 返回包含 IDFV、IDFA（如果可用）、系统版本等信息
  Future<Map<String, dynamic>?> getAttributionData() {
    return BytedancePlatform.instance.getAttributionData();
  }
}
