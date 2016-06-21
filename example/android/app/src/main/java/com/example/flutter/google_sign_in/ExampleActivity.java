// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.flutter.google_sign_in;

import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;

import io.flutter.google_sign_in.FlutterGoogleSignIn;

import com.google.android.gms.auth.api.signin.GoogleSignInOptions;

import org.chromium.base.PathUtils;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterView;

import java.io.File;

public class ExampleActivity extends FragmentActivity {
    private static final String TAG = "ExampleActivity";

    private FlutterView flutterView;
    private FlutterGoogleSignIn mGoogleSignIn;
    private static final int RC_SIGN_IN = 9001;  // Can be any integer you're not using as a request code

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        mGoogleSignIn.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        FlutterMain.ensureInitializationComplete(getApplicationContext(), null);
        setContentView(R.layout.application_layout);

        flutterView = (FlutterView) findViewById(R.id.flutter_view);
        File appBundle = new File(PathUtils.getDataDirectory(this), FlutterMain.APP_BUNDLE);
        flutterView.runFromBundle(appBundle.getPath(), null);

        GoogleSignInOptions options = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestEmail()
                // Request additional scopes here:
                // .requestScopes(new Scope("..."))
                .build();
        mGoogleSignIn = new FlutterGoogleSignIn(this, flutterView, options, RC_SIGN_IN);
    }

    @Override
    protected void onDestroy() {
        if (flutterView != null) {
            flutterView.destroy();
        }
        super.onDestroy();
    }

    @Override
    protected void onPause() {
        super.onPause();
        flutterView.onPause();
    }

    @Override
    protected void onPostResume() {
        super.onPostResume();
        flutterView.onPostResume();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        // Reload the Flutter Dart code when the activity receives an intent
        // from the "flutter refresh" command.
        // This feature should only be enabled during development.  Use the
        // debuggable flag as an indicator that we are in development mode.
        if ((getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
            if (Intent.ACTION_RUN.equals(intent.getAction())) {
                flutterView.runFromBundle(intent.getDataString(),
                                          intent.getStringExtra("snapshot"));
            }
        }
    }
}
