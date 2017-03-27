// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.googlesignin;

import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.view.WindowManager;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterView;

/** FlutterActivity class that subclasses FragmentActivity
  *
  * TODO(jackson): Should be merged into engine's FlutterActivity
  */
public class FlutterActivity extends FragmentActivity {

  private FlutterView view;

  @Override protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      Window window = getWindow();
      window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
      window.setStatusBarColor(0x40000000);
      window.getDecorView().setSystemUiVisibility(
          View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
    }

    Context applicationContext = getApplicationContext();
    FlutterMain.ensureInitializationComplete(applicationContext, null);

    view = new FlutterView(this);
    LayoutParams layoutParams = new LayoutParams(
        LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT);
    view.setLayoutParams(layoutParams);
    setContentView(view);
    view.runFromBundle(FlutterMain.findAppBundlePath(applicationContext), null);
  }

  public FlutterView getFlutterView() {
    return view;
  }

  @Override protected void onDestroy() {
    if (view != null) {
      view.destroy();
    }
    // Do we need to shut down Sky too?
    super.onDestroy();
  }

  @Override public void onBackPressed() {
    if (view != null) {
      view.popRoute();
      return;
    }
    super.onBackPressed();
  }

  @Override protected void onPause() {
    super.onPause();
    if (view != null) {
      view.onPause();
    }
  }

  @Override protected void onPostResume() {
    super.onPostResume();
    if (view != null) {
      view.onPostResume();
    }
  }
}
