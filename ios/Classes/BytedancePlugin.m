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


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [BDASignalManager registerWithOptionalData:@{}];
    [BDASignalManager enableIdfa:YES];
    [BDASignalManager didFinishLaunchingWithOptions:launchOptions connectOptions:nil];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSString *openUrl = url.absoluteString;
    [BDASignalManager anylyseDeeplinkClickidWithOpenUrl:openUrl];
    return YES;
}

- (void)uploadRegister:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString* userId = arguments[@"userId"];
    NSString* nickName = arguments[@"nickName"];
    [BDASignalManager trackEssentialEventWithName:kBDADSignalSDKEventRegister params:@{@"userId": userId, @"nickName": nickName}];
}

- (void)getIdfv:(FlutterResult)result {
    NSUUID *idfv = [[UIDevice currentDevice] identifierForVendor];
    NSString *idfvString = [idfv UUIDString];
    result(idfvString);
}

- (void)uploadLogin:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString* userId = arguments[@"userId"];
    NSString* method = arguments[@"method"];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userId) params[@"userId"] = userId;
    if (method) params[@"method"] = method;

    [BDASignalManager trackEssentialEventWithName:@"login" params:params];
    result(nil);
}

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
    result(nil);
}

- (void)uploadCustomEvent:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString* eventName = arguments[@"eventName"];
    NSDictionary* eventParams = arguments[@"params"];

    if (!eventName) {
        result([FlutterError errorWithCode:@"INVALID_PARAM" message:@"eventName is required" details:nil]);
        return;
    }

    [BDASignalManager trackEssentialEventWithName:eventName params:eventParams];
    result(nil);
}

- (void)setUserId:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString* userId = arguments[@"userId"];

    if (userId) {
        [BDASignalManager registerWithOptionalData:@{kBDADSignalSDKUserUniqueId: userId}];
    }
    result(nil);
}

- (void)clearUserId:(FlutterResult)result {
    [BDASignalManager registerWithOptionalData:@{}];
    result(nil);
}

- (void)getIdfa:(FlutterResult)result {
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);

        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);

        NSString *idfaString = [uuid UUIDString];
        result(idfaString);
    } else {
        result(nil);
    }
}

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

    result(nil);
}

- (void)trackEvent:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *eventName = arguments[@"eventName"];
    NSDictionary *params = arguments[@"params"];

    if (!eventName) {
        result([FlutterError errorWithCode:@"INVALID_PARAM" message:@"eventName is required" details:nil]);
        return;
    }

    [BDASignalManager trackEssentialEventWithName:eventName params:params];
    result(nil);
}

- (void)setDebugMode:(FlutterMethodCall *)call result:(FlutterResult)result {
    result(nil);
}

- (void)getAttributionData:(FlutterResult)result {
    NSMutableDictionary *attributionInfo = [NSMutableDictionary dictionary];

    NSUUID *idfv = [[UIDevice currentDevice] identifierForVendor];
    if (idfv) {
        attributionInfo[@"idfv"] = [idfv UUIDString];
    }

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

    attributionInfo[@"osVersion"] = [[UIDevice currentDevice] systemVersion];
    result(attributionInfo);
}

@end
