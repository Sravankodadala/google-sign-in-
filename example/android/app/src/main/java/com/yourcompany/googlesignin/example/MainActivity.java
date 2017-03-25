package com.yourcompany.googlesignin.example;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.googlesignin.GoogleSignInPlugin;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GoogleSignInPlugin.register(this);
    }
}
