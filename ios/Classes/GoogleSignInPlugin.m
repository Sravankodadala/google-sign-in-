#import "GoogleSignInPlugin.h"

@implementation GoogleSignInPlugin {
}

- (instancetype)initWithFlutterView:(FlutterViewController *)flutterView {
  self = [super init];
  if (self) {
    FlutterMethodChannel *channel = [FlutterMethodChannel
        methodChannelNamed:@"xxpluginxx"
           binaryMessenger:flutterView
                     codec:[FlutterStandardMethodCodec sharedInstance]];
    [channel setMethodCallHandler:^(FlutterMethodCall *call,
                                    FlutterResultReceiver result) {
      if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice]
                                                    systemVersion]],
               nil);
      }
    }];
  }
  return self;
}

- (BOOL)handleURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation {
  return [[GIDSignIn sharedInstance] handleURL:url
                             sourceApplication:sourceApplication
                                    annotation:annotation];
}

- (void)signIn:(GIDSignIn *)signIn
    didSignInForUser:(GIDGoogleUser *)user
           withError:(NSError *)error {
  // NSDictionary *response;
  // if (error != nil) {
  //     response = @{ @"isSuccess": @(NO) };
  // } else {
  //     NSURL *photoUrl;
  //     if (user.profile.hasImage) {
  //         // TODO(jackson): Allow configuring the image dimensions.
  //         // 256px is probably more than needed for most devices (64dp @
  //         320dpi = 128px)
  //         photoUrl = [user.profile imageURLWithDimension:256];
  //     }
  //     response = @{
  //         @"isSuccess": @(YES),
  //         @"signInAccount": @{
  //             @"displayName": user.profile.name ?: [NSNull null],
  //             @"email": user.profile.email ?: [NSNull null],
  //             @"id": user.userID ?: [NSNull null],
  //             @"idToken": user.authentication.idToken ?: [NSNull null],
  //             @"serverAuthCode": user.serverAuthCode ?: [NSNull null],
  //             @"photoUrl": [photoUrl absoluteString] ?: [NSNull null],
  //         }
  //     };
  // }
  // NSData* data = [NSJSONSerialization dataWithJSONObject:response options:0
  // error:nil];
  // NSString *message = [[NSString alloc] initWithData:data
  // encoding:NSUTF8StringEncoding];
  // void (^callback)(NSString*) = [_callbacks lastObject];
  // [_callbacks removeLastObject];
  // callback(message);
}

- (void)signIn:(GIDSignIn *)signIn
    didDisconnectWithUser:(GIDGoogleUser *)user
                withError:(NSError *)error {
  // NSDictionary *response = @{ @"isSuccess": @(YES) };
  // NSData* data = [NSJSONSerialization dataWithJSONObject:response options:0
  // error:nil];
  // NSString *message = [[NSString alloc] initWithData:data
  // encoding:NSUTF8StringEncoding];
  // ((void(^)(NSString*))[_callbacks lastObject])(message);
  // [_callbacks removeLastObject];
}

@end
