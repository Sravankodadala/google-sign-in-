# Google Sign In Example

This Flutter example project shows how to use the
[google_sign_in Dart package](https://github.com/flutter/google_sign_in).

Note: The Google Sign-In SDK is currently only supported on iOS simulator.
Support for Android and [iOS devices](https://github.com/flutter/flutter/issues/2740) is coming soon!

## Getting started

Go to the [Google Sign-In SDK instructions](https://developers.google.com/identity/sign-in/ios/sdk/)
and follow the instructions to get a configuration file.

Edit Info.plist, update the CFBundleURLTypes to match your bundle ID and reversed client ID from your configuration file.

Edit lib/main.dart, updating _kClientId with your app's client id.

Launch the iOS simulator

Type ```flutter run```. (You may need to update the path to flutter in pubspec.yaml.)

Use the "SIGN IN" button to authenticate. You should see your name and profile picture after a successful login.

