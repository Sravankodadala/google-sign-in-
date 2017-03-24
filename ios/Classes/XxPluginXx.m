#import "XxPluginXx.h"

@implementation XxPluginXx {
}

- (instancetype) initWithFlutterView: (FlutterViewController *)flutterView {
  self = [super init];
  if (self) {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                        methodChannelNamed:@"xxpluginxx"
                                        binaryMessenger:flutterView
                                        codec:[FlutterStandardMethodCodec sharedInstance]];
    [channel setMethodCallHandler:^(FlutterMethodCall* call,
                                    FlutterResultReceiver result) {
      if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]], nil);
      }
    }];
  }
  return self;
}

@end

