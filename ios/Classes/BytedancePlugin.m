#import "BytedancePlugin.h"
#import <BDASignalSDK/BDASignalManager.h>
#import <BDASignalSDK/BDASignalDefinitions.h>
#import <AdSupport/AdSupport.h>

@interface BytedancePlugin ()
@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, strong) NSDictionary *pendingDeepLinkData;
@property (nonatomic, copy) NSString *currentUserId;
@property (nonatomic, assign) BOOL isInitialized;
@property (nonatomic, strong) NSDictionary *launchOptions;
@end

@implementation BytedancePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"bytedance"
            binaryMessenger:[registrar messenger]];
  BytedancePlugin* instance = [[BytedancePlugin alloc] init];
  instance.channel = channel;
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
  } else if ([@"uploadActiveRegister" isEqualToString:call.method]) {
        [self uploadActiveRegister:call result:result];
  } else if ([@"requestAttribution" isEqualToString:call.method]) {
        [self requestAttribution:result];
  } else if ([@"getCachedAttributionData" isEqualToString:call.method]) {
        [self getCachedAttributionData:result];
  } else if ([@"getPendingDeepLink" isEqualToString:call.method]) {
        [self getPendingDeepLink:result];
  } else if ([@"clearPendingDeepLink" isEqualToString:call.method]) {
        [self clearPendingDeepLink:result];
  } else if ([@"trackAppActivate" isEqualToString:call.method]) {
        [self trackAppActivate:call result:result];
  } else if ([@"trackAppDeactivate" isEqualToString:call.method]) {
        [self trackAppDeactivate:result];
  } else if ([@"trackPageView" isEqualToString:call.method]) {
        [self trackPageView:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.launchOptions = launchOptions;
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if (self.isInitialized) {
        NSString *openUrl = url.absoluteString;
        [BDASignalManager anylyseDeeplinkClickidWithOpenUrl:openUrl];
        [self handleDeepLink:url];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    if (self.isInitialized && [userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *webpageURL = userActivity.webpageURL;
        if (webpageURL) {
            [BDASignalManager anylyseDeeplinkClickidWithOpenUrl:webpageURL.absoluteString];
            [self handleDeepLink:webpageURL];
        }
    }
    return YES;
}

- (void)handleDeepLink:(NSURL *)url {
    if (!url) return;

    NSMutableDictionary *deepLinkData = [NSMutableDictionary dictionary];
    deepLinkData[@"deepLink"] = url.absoluteString;

    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *item in components.queryItems) {
        if (item.value) {
            params[item.name] = item.value;
        }
    }
    if (params.count > 0) {
        deepLinkData[@"params"] = [params copy];
    }

    self.pendingDeepLinkData = [deepLinkData copy];
    [self notifyDeepLinkReceived:deepLinkData];
}

- (void)notifyDeepLinkReceived:(NSDictionary *)data {
    if (self.channel) {
        [self.channel invokeMethod:@"onDeepLinkReceived" arguments:data];
    }
}

- (FlutterError *)sdkNotInitializedError {
    return [FlutterError errorWithCode:@"SDK_NOT_INITIALIZED"
                               message:@"SDK not initialized. Please call initSdk first."
                               details:nil];
}

- (void)uploadRegister:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (!self.isInitialized) {
        result([self sdkNotInitializedError]);
        return;
    }
    NSDictionary *arguments = call.arguments;
    NSString* userId = arguments[@"userId"];
    NSString* nickName = arguments[@"nickName"];
    [BDASignalManager trackEssentialEventWithName:kBDADSignalSDKEventRegister params:@{@"userId": userId, @"nickName": nickName}];
    result(@YES);
}

- (void)getIdfv:(FlutterResult)result {
    NSUUID *idfv = [[UIDevice currentDevice] identifierForVendor];
    NSString *idfvString = [idfv UUIDString];
    result(idfvString);
}

- (void)uploadLogin:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (!self.isInitialized) {
        result([self sdkNotInitializedError]);
        return;
    }
    NSDictionary *arguments = call.arguments;
    NSString* userId = arguments[@"userId"];
    NSString* method = arguments[@"method"];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userId) params[@"userId"] = userId;
    if (method) params[@"method"] = method;

    [BDASignalManager trackEssentialEventWithName:@"login" params:params];
    result(@YES);
}

- (void)uploadPurchase:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (!self.isInitialized) {
        result([self sdkNotInitializedError]);
        return;
    }
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
    result(@YES);
}

- (void)uploadCustomEvent:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (!self.isInitialized) {
        result([self sdkNotInitializedError]);
        return;
    }
    NSDictionary *arguments = call.arguments;
    NSString* eventName = arguments[@"eventName"];
    NSDictionary* eventParams = arguments[@"params"];

    if (!eventName) {
        result([FlutterError errorWithCode:@"INVALID_PARAM" message:@"eventName is required" details:nil]);
        return;
    }

    [BDASignalManager trackEssentialEventWithName:eventName params:eventParams];
    result(@YES);
}

- (void)setUserId:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (!self.isInitialized) {
        result([self sdkNotInitializedError]);
        return;
    }
    NSDictionary *arguments = call.arguments;
    NSString* userId = arguments[@"userId"];

    if (userId) {
        self.currentUserId = userId;
        [BDASignalManager registerWithOptionalData:@{kBDADSignalSDKUserUniqueId: userId}];
    }
    result(@YES);
}

- (void)clearUserId:(FlutterResult)result {
    if (!self.isInitialized) {
        result([self sdkNotInitializedError]);
        return;
    }
    self.currentUserId = nil;
    [BDASignalManager registerWithOptionalData:@{}];
    result(@YES);
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
    if (self.isInitialized) {
        NSLog(@"[BytedancePlugin] SDK already initialized");
        result(@YES);
        return;
    }

    NSDictionary *arguments = call.arguments;
    NSString *userId = arguments[@"userId"];
    NSNumber *enableIdfa = arguments[@"enableIdfa"];
    NSNumber *isDebug = arguments[@"isDebug"];
    NSString *appId = arguments[@"appId"];
    NSString *appName = arguments[@"appName"];
    NSString *channel = arguments[@"channel"];

    NSMutableDictionary *optionalData = [NSMutableDictionary dictionary];
    if (userId) {
        optionalData[kBDADSignalSDKUserUniqueId] = userId;
        self.currentUserId = userId;
    }
    if (appId) {
        optionalData[@"appId"] = appId;
    }
    if (appName) {
        optionalData[@"appName"] = appName;
    }
    if (channel) {
        optionalData[@"channel"] = channel;
    }

    [BDASignalManager registerWithOptionalData:optionalData];

    if (enableIdfa && [enableIdfa boolValue]) {
        [BDASignalManager enableIdfa:YES];
    }

    if (isDebug && [isDebug boolValue]) {
        NSLog(@"[BytedancePlugin] Debug mode enabled");
    }

    [BDASignalManager didFinishLaunchingWithOptions:self.launchOptions connectOptions:nil];

    NSURL *url = self.launchOptions[UIApplicationLaunchOptionsURLKey];
    if (url) {
        [self handleDeepLink:url];
    }

    self.isInitialized = YES;
    NSLog(@"[BytedancePlugin] SDK initialized successfully");

    result(@YES);
}

- (void)trackEvent:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (!self.isInitialized) {
        result([self sdkNotInitializedError]);
        return;
    }
    NSDictionary *arguments = call.arguments;
    NSString *eventName = arguments[@"eventName"];
    NSDictionary *params = arguments[@"params"];

    if (!eventName) {
        result([FlutterError errorWithCode:@"INVALID_PARAM" message:@"eventName is required" details:nil]);
        return;
    }

    [BDASignalManager trackEssentialEventWithName:eventName params:params];
    result(@YES);
}

- (void)setDebugMode:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (!self.isInitialized) {
        result([self sdkNotInitializedError]);
        return;
    }
    NSDictionary *arguments = call.arguments;
    NSNumber *enable = arguments[@"enable"];

    if (enable != nil) {
        NSLog(@"[BytedancePlugin] Debug mode: %@", [enable boolValue] ? @"enabled" : @"disabled");
    }
    result(@YES);
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
    attributionInfo[@"platform"] = @"iOS";
    if (self.currentUserId) {
        attributionInfo[@"userId"] = self.currentUserId;
    }
    result(attributionInfo);
}

- (void)uploadActiveRegister:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (!self.isInitialized) {
        result([self sdkNotInitializedError]);
        return;
    }
    NSDictionary *arguments = call.arguments;
    NSString *userId = arguments[@"userId"];
    NSString *registerType = arguments[@"registerType"];
    NSString *channel = arguments[@"channel"];
    NSDictionary *extraParams = arguments[@"extraParams"];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userId) params[@"userId"] = userId;
    if (registerType) params[@"registerType"] = registerType;
    if (channel) params[@"channel"] = channel;

    if (extraParams) {
        [params addEntriesFromDictionary:extraParams];
    }

    [BDASignalManager trackEssentialEventWithName:@"active_register" params:params];
    result(@YES);
}

- (void)requestAttribution:(FlutterResult)result {
    if (!self.isInitialized) {
        result([self sdkNotInitializedError]);
        return;
    }
    NSLog(@"[BytedancePlugin] requestAttribution called (SDK handles this automatically)");
    result(@YES);
}

- (void)getCachedAttributionData:(FlutterResult)result {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];

    NSUUID *idfv = [[UIDevice currentDevice] identifierForVendor];
    if (idfv) {
        data[@"idfv"] = [idfv UUIDString];
    }

    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);

        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);

        if (uuid) {
            data[@"idfa"] = [uuid UUIDString];
        }
    }

    data[@"osVersion"] = [[UIDevice currentDevice] systemVersion];
    data[@"platform"] = @"iOS";
    if (self.currentUserId) {
        data[@"userId"] = self.currentUserId;
    }

    result([data copy]);
}

- (void)getPendingDeepLink:(FlutterResult)result {
    result(self.pendingDeepLinkData);
}

- (void)clearPendingDeepLink:(FlutterResult)result {
    self.pendingDeepLinkData = nil;
    result(@YES);
}

- (void)trackAppActivate:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (!self.isInitialized) {
        result([self sdkNotInitializedError]);
        return;
    }
    NSDictionary *arguments = call.arguments;
    NSString *userId = arguments[@"userId"];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userId) params[@"userId"] = userId;

    [BDASignalManager trackEssentialEventWithName:@"app_activate" params:params];
    result(@YES);
}

- (void)trackAppDeactivate:(FlutterResult)result {
    if (!self.isInitialized) {
        result([self sdkNotInitializedError]);
        return;
    }
    [BDASignalManager trackEssentialEventWithName:@"app_deactivate" params:@{}];
    result(@YES);
}

- (void)trackPageView:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (!self.isInitialized) {
        result([self sdkNotInitializedError]);
        return;
    }
    NSDictionary *arguments = call.arguments;
    NSString *pageName = arguments[@"pageName"];
    NSString *pageUrl = arguments[@"pageUrl"];
    NSString *referrer = arguments[@"referrer"];
    NSDictionary *extraParams = arguments[@"extraParams"];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (pageName) params[@"pageName"] = pageName;
    if (pageUrl) params[@"pageUrl"] = pageUrl;
    if (referrer) params[@"referrer"] = referrer;

    if (extraParams) {
        [params addEntriesFromDictionary:extraParams];
    }

    [BDASignalManager trackEssentialEventWithName:@"page_view" params:params];
    result(@YES);
}

@end
