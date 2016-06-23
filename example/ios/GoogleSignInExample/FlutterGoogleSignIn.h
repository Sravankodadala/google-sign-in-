// Copyright 2016, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <Google/SignIn.h>
#import <UIKit/UIKit.h>

// TODO(jackson): Move this interface into a CocoaPod
@interface FlutterGoogleSignIn : NSObject <GIDSignInDelegate, GIDSignInUIDelegate, FlutterAsyncMessageListener>
- (id)initWithController:(FlutterViewController*)controller;
- (BOOL)application:(UIApplication*)app
            openURL:(NSURL*)url
  sourceApplication:(NSString*)sourceApplication
         annotation:(id)annotation;
@end
