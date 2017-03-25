#import "GoogleSignInPlugin.h"

@implementation GoogleSignInPlugin {
  NSMutableArray* _callbacks;
}

- (instancetype)initWithFlutterView:(FlutterViewController *)flutterView {
  self = [super init];
  if (self) {
    FlutterMethodChannel *channel = [FlutterMethodChannel
        methodChannelNamed:@"plugins.flutter.io/google_sign_in"
           binaryMessenger:flutterView
                     codec:[FlutterStandardMethodCodec sharedInstance]];
    [GIDSignIn sharedInstance].uiDelegate = flutterView;
    [channel setMethodCallHandler:^(FlutterMethodCall *call,
                                    FlutterResultReceiver result) {
      [self handleMethodCall:call result:result];
    }];
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResultReceiver)result {
    if ([call.method isEqualToString:@"init"]) {
        [GIDSignIn sharedInstance].clientID = call.arguments[@"clientId"];
        [GIDSignIn sharedInstance].scopes = call.arguments[@"scopes"];
        [GIDSignIn sharedInstance].hostedDomain = call.arguments[@"hostedDomain"];
        result(@{ @"success" : @(YES) }, nil);
    } else if ([call.method isEqualToString:@"signInSilently"]) {
        [_callbacks insertObject:result atIndex:0];
        [[GIDSignIn sharedInstance] signInSilently];
    } else if ([call.method isEqualToString:@"signIn"]) {
        [_callbacks insertObject:result atIndex:0];
        [[GIDSignIn sharedInstance] signIn];
    } else if ([call.method isEqualToString:@"getToken"]) {
        GIDGoogleUser *currentUser = [GIDSignIn sharedInstance].currentUser;
        GIDAuthentication *auth = currentUser.authentication;
        [auth getTokensWithHandler:^void(GIDAuthentication* authentication,
                                         NSError* error) {
            NSDictionary* response;
            if (error == nil) {
                response = @{
                             @"success" : @(YES),
                             @"token" : authentication.accessToken,
                             };
            } else {
                response = @{
                             @"success" : @(NO),
                             @"reason" : error.domain,
                             @"detail" : error.localizedDescription,
                             };
            }
            result(response, nil);
        }];
    } else if ([call.method isEqualToString:@"signOut"]) {
        [[GIDSignIn sharedInstance] signOut];
        result(@{ @"success" : @(YES) }, nil);
    } else if ([call.method isEqualToString:@"disconnect"]) {
        [_callbacks insertObject:result atIndex:0];
        [[GIDSignIn sharedInstance] disconnect];
    } else {
        [NSException
         raise:@"Unexpected argument"
         format:@"FlutterGoogleSignIn received an unexpected method call"];
    }
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
