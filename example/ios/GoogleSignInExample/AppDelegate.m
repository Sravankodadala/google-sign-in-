// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "AppDelegate.h"
#import "FlutterGoogleSignIn.h"

#import <Flutter/Flutter.h>

@implementation AppDelegate {
    FlutterGoogleSignIn* _googleSignIn;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    FlutterDartProject* project = [[FlutterDartProject alloc] initFromDefaultSourceForConfiguration];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    FlutterViewController* flutterController = [[FlutterViewController alloc] initWithProject:project
                                                                                      nibName:nil
                                                                                       bundle:nil];
    _googleSignIn = [[FlutterGoogleSignIn alloc] initWithController:flutterController];

    self.window.rootViewController = flutterController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

@end
