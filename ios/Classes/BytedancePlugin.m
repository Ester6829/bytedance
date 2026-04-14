#import "BytedancePlugin.h"
#import <BDASignalSDK/BDASignalManager.h>
#import <BDASignalSDK/BDASignalDefinitions.h>

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
  } else if ([@"getIdfv" isEqualToString:call.method]) {
        [self getIdfv:result];
  } else if ([@"getAndroidId" isEqualToString:call.method]) {
        result(nil);
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
@end
  