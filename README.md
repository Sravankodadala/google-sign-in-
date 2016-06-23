A Dart wrapper for [Google Sign In](https://developers.google.com/identity/).

#### Building the example

If you use the "example" project as a starting point:

Update android/local.properties to add flutter.sdk=/path/to/flutter/sdk

For Android, go to the [Android Sign-In SDK instructions](https://developers.google.com/identity/sign-in/android/start)
and follow the instructions to download a google-services.json file. Move this file
to ```android/app/google-services.json```. You can now open the example/android folder in Android Studio and run the app on an Android device.


For iOS, make sure you have CocoaPods installed and run ```pod install``` in the example/ios folder. You can now open ```example/ios/GoogleSignInExample.xcworkspace``` in Xcode. Go to the [iOS Sign-In SDK instructions](https://developers.google.com/identity/sign-in/ios/start) and follow the instructions to add a GoogleServices-Info.plist file to your project and to set up a URL type for REVERSED_CLIENT_ID to handle the callback. You should now be able to sign in through the iOS simulator or on a device.

#### Adding to an existing Android project

Go to the [Android Sign-In SDK instructions](https://developers.google.com/identity/sign-in/android/start)
and follow the instructions to download a google-services.json file. Move this file
to your application's ```android/app/google-services.json``` directory.

Add google_sign_in as a dependency in your pubspec.yaml.

Add the following to your Android buildscript dependencies in the project root build.gradle:

```
    classpath 'com.google.gms:google-services:3.0.0'
```

Add the following to your application's build.gradle

```
dependencies {
    compile 'com.google.android.gms:play-services-auth:9.0.2'
    compile 'io.flutter.google_sign_in:google-sign-in:0.0.1'
}
apply plugin: 'com.google.gms.google-services'
```

In your activity class, add the following:

```
    private FlutterGoogleSignIn mGoogleSignIn;
    private static final int RC_SIGN_IN = 9001;  // Can be any integer you're not using as a request code
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        mGoogleSignIn.onActivityResult(requestCode, resultCode, data);
    }
```

At the end of your activity's onCreate method, add the following:

```
        GoogleSignInOptions options = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestEmail()
                // Request additional scopes like this:
                // .requestScopes(new Scope("..."))
                .build();
        mGoogleSignIn = new FlutterGoogleSignIn(this, flutterView, options, RC_SIGN_IN);
```

In your Dart code, you can now call APIs like GoogleSignIn.signIn(). Refer to the example app or the [API documentation](http://flutter.github.io/google_sign_in/) for usage.

#### Compiling from source

If you want to make changes to the FlutterGoogleSignIn class, you'll need to build from source rather than using the published binaries.

In your application's build.gradle, change ```compile 'io.flutter.google_sign_in:google-sign-in:9.0.2``` to ```compile project(':googleSignIn')```.

Create a soft link called googleSignIn in the ```android``` folder of your application. It should point to the ```android``` folder in the root of this repository.

Add ':googleSignIn' to the list of includes in your application's settings.gradle.

Copy bin/cache/artifacts/engine/android-arm/flutter.jar from your Flutter SDK into android/libs

Run ```zip -d flutter.jar "assets/*" "lib/*"``` in the android/libs directory.

You should now be able to build from source using Android Studio.

#### Adding to an existing iOS project

Instructions for adding to an existing iOS project are coming soon.
