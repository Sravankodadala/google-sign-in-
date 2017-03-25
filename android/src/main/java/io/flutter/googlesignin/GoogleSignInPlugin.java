package io.flutter.googlesignin;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.FlutterMethodChannel;
import io.flutter.plugin.common.FlutterMethodChannel.MethodCallHandler;
import io.flutter.plugin.common.FlutterMethodChannel.Response;
import io.flutter.plugin.common.MethodCall;

import java.util.HashMap;
import java.util.Map;

/**
 * GoogleSignIn
 */
public class GoogleSignInPlugin implements MethodCallHandler {
  private FlutterActivity activity;

  public static void register(FlutterActivity activity) {
    new GoogleSignInPlugin(activity);
  }

  private GoogleSignInPlugin(FlutterActivity activity) {
    this.activity = activity;
    new FlutterMethodChannel(activity.getFlutterView(), "google_sign_in").setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, Response response) {
    if (call.method.equals("getPlatformVersion")) {
      response.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      throw new IllegalArgumentException("Unknown method " + call.method);
    }
  }
}
