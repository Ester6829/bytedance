#import "BytedancePlugin.h"
#import <BDASignalSDK/BDASignalManager.h>
#import <BDASignalSDK/BDASignalDefinitions.h>
#import <AdSupport/AdSupport.h>

@implementation BytedancePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"bytedance"
            binaryMessenger:[registrar messenger]];
  BytedancePlugin* instance = [[BytedancePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  [registrar addApplicationDelegate:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"uploadRegister" isEqualToString:call.method]) {
        [self uploadRegister:call result:result];
  } else if ([@"uploadLogin" isEqualToString:call.method]) {
        [self uploadLogin:call result:result];
  } else if ([@"uploadPurchase" isEqualToString:call.method]) {
        [self uploadPurchase:call result:result];
  } else if ([@"uploadCustomEvent" isEqualToString:call.method]) {
        [self uploadCustomEvent:call result:result];
  } else if ([@"getIdfv" isEqualToString:call.method]) {
        [self getIdfv:result];
  } else if ([@"getIdfa" isEqualToString:call.method]) {
        [self getIdfa:result];
  } else if ([@"getAndroidId" isEqualToString:call.method]) {
        result(nil);
  } else if ([@"setUserId" isEqualToString:call.method]) {
        [self setUserId:call result:result];
  } else if ([@"clearUserId" isEqualToString:call.method]) {
        [self clearUserId:result];
  } else if ([@"initSdk" isEqualToString:call.method]) {
        [self initSdk:call result:result];
  } else if ([@"trackEvent" isEqualToString:call.method]) {
        [self trackEvent:call result:result];
  } else if ([@"setDebugMode" isEqualToString:call.method]) {
        [self setDebugMode:call result:result];
  } else if ([@"getAttributionData" isEqualToString:call.method]) {
        [self getAttributionData:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}


//原本巨量引擎方法
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 注册可选参数
    [BDASignalManager registerWithOptionalData:@{
       // kBDADSignalSDKUserUniqueId : @"3y48693232"  // 业务用户id，非必传
    }];
    //idfa开关，默认为NO，建议在用户同意隐私政策后调用，并且在didFinishLaunchingWithOptions方法中调用
    [BDASignalManager enableIdfa:YES];
    // 上报冷启动事件
    [BDASignalManager didFinishLaunchingWithOptions:launchOptions connectOptions:nil];

    NSLog(@"=======> 巨量营销 SDK 已启动，App ID 从 Info.plist 读取");

    return YES;
}

//deeplink click回调方法，需在info.plist中配置URL Types，且URL Schemes必须以"tt"开头
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    // 将url参数转换成string类型之后，传递给SDK
    NSString *openUrl = url.absoluteString;
    [BDASignalManager anylyseDeeplinkClickidWithOpenUrl:openUrl];
    return YES;
}

// 上报注册事件
- (void)uploadRegister:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString* userId = arguments[@"userId"];
    NSString* nickName = arguments[@"nickName"];
    [BDASignalManager trackEssentialEventWithName:kBDADSignalSDKEventRegister params:@{@"userId": userId, @"nickName": nickName}];
 
    NSLog(@"=======> 注册事件上报，userId: %@, nickName: %@", userId, nickName);

}

// 获取 IDFV
- (void)getIdfv:(FlutterResult)result {
    NSUUID *idfv = [[UIDevice currentDevice] identifierForVendor];
    NSString *idfvString = [idfv UUIDString];
    NSLog(@"=======> IDFV: %@", idfvString);
    result(idfvString);
}

// 上报登录事件
- (void)uploadLogin:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString* userId = arguments[@"userId"];
    NSString* method = arguments[@"method"]; // 登录方式：如 "password", "sms", "wechat" 等

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userId) params[@"userId"] = userId;
    if (method) params[@"method"] = method;

    [BDASignalManager trackEssentialEventWithName:@"login" params:params];
    NSLog(@"=======> 登录事件上报，params: %@", params);
    result(nil);
}

// 上报购买事件
- (void)uploadPurchase:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString* orderId = arguments[@"orderId"];
    NSNumber* amount = arguments[@"amount"];
    NSString* currency = arguments[@"currency"] ?: @"CNY";
    NSString* productId = arguments[@"productId"];
    NSString* productName = arguments[@"productName"];
    NSNumber* quantity = arguments[@"quantity"];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (orderId) params[@"orderId"] = orderId;
    if (amount) params[@"amount"] = amount;
    params[@"currency"] = currency;
    if (productId) params[@"productId"] = productId;
    if (productName) params[@"productName"] = productName;
    if (quantity) params[@"quantity"] = quantity;

    [BDASignalManager trackEssentialEventWithName:@"purchase" params:params];
    NSLog(@"=======> 购买事件上报，params: %@", params);
    result(nil);
}

// 上报自定义事件
- (void)uploadCustomEvent:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString* eventName = arguments[@"eventName"];
    NSDictionary* eventParams = arguments[@"params"];

    if (!eventName) {
        result([FlutterError errorWithCode:@"INVALID_PARAM" message:@"eventName is required" details:nil]);
        return;
    }

    [BDASignalManager trackEssentialEventWithName:eventName params:eventParams];
    NSLog(@"=======> 自定义事件上报，eventName: %@, params: %@", eventName, eventParams);
    result(nil);
}

// 设置用户ID
- (void)setUserId:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString* userId = arguments[@"userId"];

    if (userId) {
        [BDASignalManager registerWithOptionalData:@{kBDADSignalSDKUserUniqueId: userId}];
        NSLog(@"=======> 设置用户ID: %@", userId);
    }
    result(nil);
}

// 清除用户ID
- (void)clearUserId:(FlutterResult)result {
    [BDASignalManager registerWithOptionalData:@{}];
    NSLog(@"=======> 清除用户ID");
    result(nil);
}

// 获取 IDFA
- (void)getIdfa:(FlutterResult)result {
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);

        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);

        NSString *idfaString = [uuid UUIDString];
        NSLog(@"=======> IDFA: %@", idfaString);
        result(idfaString);
    } else {
        result(nil);
    }
}

// 初始化 SDK（显式调用）
- (void)initSdk:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *userId = arguments[@"userId"];
    NSNumber *enableIdfa = arguments[@"enableIdfa"];
    NSNumber *isDebug = arguments[@"isDebug"];

    NSMutableDictionary *optionalData = [NSMutableDictionary dictionary];
    if (userId) {
        optionalData[kBDADSignalSDKUserUniqueId] = userId;
    }

    [BDASignalManager registerWithOptionalData:optionalData];

    if (enableIdfa && [enableIdfa boolValue]) {
        [BDASignalManager enableIdfa:YES];
    }

    // 注意：openDebugLog 方法在当前 BDASignalSDK 版本中不可用
    if (isDebug && [isDebug boolValue]) {
        NSLog(@"=======> 调试模式已开启（日志通过 NSLog 输出）");
    }

    NSLog(@"=======> 巨量营销 SDK 初始化成功, userId: %@, enableIdfa: %@", userId, enableIdfa);
    result(nil);
}

// 通用事件追踪方法
- (void)trackEvent:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *eventName = arguments[@"eventName"];
    NSDictionary *params = arguments[@"params"];

    if (!eventName) {
        result([FlutterError errorWithCode:@"INVALID_PARAM" message:@"eventName is required" details:nil]);
        return;
    }

    [BDASignalManager trackEssentialEventWithName:eventName params:params];
    NSLog(@"=======> 事件上报，eventName: %@, params: %@", eventName, params);
    result(nil);
}

// 设置调试模式
- (void)setDebugMode:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSNumber *enable = arguments[@"enable"];

    BOOL isDebug = enable ? [enable boolValue] : NO;
    // 注意：openDebugLog 方法在当前 BDASignalSDK 版本中不可用
    // 我们仅记录日志，表示调试模式状态变更
    NSLog(@"=======> 调试模式: %@", isDebug ? @"开启" : @"关闭");
    result(nil);
}

// 获取归因数据
- (void)getAttributionData:(FlutterResult)result {
    // BDASignalSDK 会自动处理归因，这里提供获取相关设备信息的方法
    NSMutableDictionary *attributionInfo = [NSMutableDictionary dictionary];

    // IDFV
    NSUUID *idfv = [[UIDevice currentDevice] identifierForVendor];
    if (idfv) {
        attributionInfo[@"idfv"] = [idfv UUIDString];
    }

    // IDFA (如果可用)
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);

        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);

        if (uuid) {
            attributionInfo[@"idfa"] = [uuid UUIDString];
        }
    }

    // 系统版本
    attributionInfo[@"osVersion"] = [[UIDevice currentDevice] systemVersion];

    NSLog(@"=======> 归因数据: %@", attributionInfo);
    result(attributionInfo);
}

@end
  