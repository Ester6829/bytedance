#import "BytedancePlugin.h"
#import <BDASignalSDK/BDASignalManager.h>
#import <BDASignalSDK/BDASignalDefinitions.h>

@interface BytedancePlugin ()
@property (nonatomic, strong) FlutterMethodChannel *channel;
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
  if ([@"initSdk" isEqualToString:call.method]) {
        [self initSdk:call result:result];
  } else if ([@"getId" isEqualToString:call.method]) {
        [self getId:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.launchOptions = launchOptions;
    return YES;
}

- (void)getId:(FlutterResult)result {
    NSUUID *idfv = [[UIDevice currentDevice] identifierForVendor];
    NSString *idfvString = [idfv UUIDString];
    result(idfvString);
}

- (void)initSdk:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (self.isInitialized) { 
        result(@YES);
        return;
    }

    [BDASignalManager registerWithOptionalData:@{}];
    [BDASignalManager didFinishLaunchingWithOptions:self.launchOptions connectOptions:nil];

    self.isInitialized = YES; 

    result(@YES);
}

@end
