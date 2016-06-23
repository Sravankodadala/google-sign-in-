// Copyright 2016, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "FlutterGoogleSignIn.h"

// TODO(jackson): Move this implementation into a CocoaPod
@implementation FlutterGoogleSignIn {
    __weak FlutterViewController *_controller;
    NSMutableArray *_callbacks;
}

- (id)initWithController:(FlutterViewController*)controller
{
    if (self = [super init]) {
        _controller = controller;
        NSError* configureError;
        [[GGLContext sharedInstance] configureWithError: &configureError];
        NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
        [GIDSignIn sharedInstance].delegate = self;
        [GIDSignIn sharedInstance].uiDelegate = (id)controller;
        [_controller addAsyncMessageListener:self];
        _callbacks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)application:(UIApplication*)app
            openURL:(NSURL*)url
  sourceApplication:(NSString*)sourceApplication
         annotation:(id)annotation {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

-     (void)signIn:(GIDSignIn *)signIn
  didSignInForUser:(GIDGoogleUser *)user
         withError:(NSError *)error {
    NSDictionary *response;
    if (error != nil) {
        response = @{ @"isSuccess": @(NO) };
    } else {
        NSURL *photoUrl;
        if (user.profile.hasImage) {
            // TODO(jackson): Allow configuring the image dimensions.
            // 256px is probably more than needed for most devices (64dp @ 320dpi = 128px)
            photoUrl = [user.profile imageURLWithDimension:256];
        }
        response = @{
            @"isSuccess": @(YES),
            @"signInAccount": @{
                @"displayName": user.profile.name ?: [NSNull null],
                @"email": user.profile.email ?: [NSNull null],
                @"id": user.userID ?: [NSNull null],
                @"idToken": user.authentication.idToken ?: [NSNull null],
                @"serverAuthCode": user.serverAuthCode ?: [NSNull null],
                @"photoUrl": [photoUrl absoluteString] ?: [NSNull null],
            }
        };
    }
    NSData* data = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    void (^callback)(NSString*) = [_callbacks lastObject];
    [_callbacks removeLastObject];
    callback(message);
}

-          (void)signIn:(GIDSignIn *)signIn
  didDisconnectWithUser:(GIDGoogleUser *)user
              withError:(NSError *)error {
    NSDictionary *response = @{ @"isSuccess": @(YES) };
    NSData* data = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    ((void(^)(NSString*))[_callbacks lastObject])(message);
    [_callbacks removeLastObject];
}

- (void)didReceiveString:(NSString*)message
                callback:(void(^)(NSString*))sendResponse
{
    [_callbacks insertObject:sendResponse atIndex:0];
    NSString *method;
    NSError *error = nil;
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error == nil) {
        method = [jsonObject objectForKey:@"method"];
    }
    if ([method isEqualToString:@"signInSilently"]) {
        [[GIDSignIn sharedInstance] signInSilently];
    } else if ([method isEqualToString:@"signIn"]) {
        [[GIDSignIn sharedInstance] signIn];
    } else if ([method isEqualToString:@"signOut"]) {
        [[GIDSignIn sharedInstance] signOut];
    } else if ([method isEqualToString:@"disconnect"]) {
        [[GIDSignIn sharedInstance] disconnect];
    } else {
        [NSException raise:@"JSON parsing error" format:@"FlutterGoogleSignIn received an unexpected JSON message"];
    }
}

- (NSString *)messageName {
    return @"GoogleSignIn";
}

- (void)dealloc {
    [_controller removeAsyncMessageListener:self];
    _controller = nil;
}

@end