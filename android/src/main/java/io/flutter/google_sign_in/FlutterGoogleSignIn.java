// Copyright 2016, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
package io.flutter.google_sign_in;

import android.content.Context;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.v4.app.FragmentActivity;
import android.util.Log;

import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInResult;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.auth.api.Auth;
import com.google.android.gms.common.api.OptionalPendingResult;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.common.api.PendingResult;
import com.google.android.gms.common.api.Status;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.view.FlutterView;

public class FlutterGoogleSignIn implements FlutterView.OnMessageListenerAsync, GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener {
    private static final String TAG = "FlutterGoogleSignIn";
    private GoogleApiClient mGoogleApiClient;
    private FragmentActivity mActivity;
    private FlutterView mFlutterView;
    private GoogleSignInOptions mOptions;
    private int mRequestCode;
    private FlutterView.MessageResponse mSignInResponse;

    public FlutterGoogleSignIn(FragmentActivity activity, FlutterView flutterView, GoogleSignInOptions options, int requestCode) {
        mActivity = activity;
        mFlutterView = flutterView;
        mOptions = options;
        mRequestCode = requestCode;
        GoogleApiClient.Builder builder = new GoogleApiClient.Builder(mActivity)
                .enableAutoManage(activity, this)
                .addApi(Auth.GOOGLE_SIGN_IN_API, options)
                .addConnectionCallbacks(this);
        mGoogleApiClient = builder.build();
        flutterView.addOnMessageListenerAsync("GoogleSignIn", this);
    }

    @Override
    public void onMessage(String message, final FlutterView.MessageResponse messageResponse) {
        String method;
        try {
            JSONObject json = new JSONObject(message);
            method = json.getString("method");
        } catch (JSONException e) {
            Log.e(TAG, "JSON exception", e);
            return;
        }
        switch (method) {
            case "signInSilently":
                OptionalPendingResult<GoogleSignInResult> pendingResult =
                        Auth.GoogleSignInApi.silentSignIn(mGoogleApiClient);
                if (pendingResult.isDone()) {
                    messageResponse.send(buildJson(pendingResult.get()));
                } else {
                    pendingResult.setResultCallback(new ResultCallback<GoogleSignInResult>() {
                        @Override
                        public void onResult(GoogleSignInResult result) {
                            messageResponse.send(buildJson(result));
                        }
                    });
                }
                break;
            case "signIn":
                mSignInResponse = messageResponse;
                Intent signInIntent = Auth.GoogleSignInApi.getSignInIntent(mGoogleApiClient);
                mActivity.startActivityForResult(signInIntent, mRequestCode);
                break;
            case "signOut":
                Auth.GoogleSignInApi.signOut(mGoogleApiClient).setResultCallback(new ResultCallback<Status>() {
                    @Override
                    public void onResult(Status status) {
                        messageResponse.send(buildJson(null));
                    }
                });
                break;
            case "disconnect":
                Auth.GoogleSignInApi.revokeAccess(mGoogleApiClient).setResultCallback(new ResultCallback<Status>() {
                    @Override
                    public void onResult(Status status) {
                        messageResponse.send(buildJson(null));
                    }
                });
                break;
        }
    }

    private static String buildJson(GoogleSignInResult result) {
        if (result != null) {
            try {
                JSONObject json = new JSONObject();
                json.put("isSuccess", result.isSuccess());
                if (result.getSignInAccount() != null) {
                    JSONObject signInAccount = new JSONObject();
                    json.put("signInAccount", signInAccount);
                    GoogleSignInAccount account = result.getSignInAccount();
                    signInAccount.put("displayName", account.getDisplayName());
                    signInAccount.put("email", account.getEmail());
                    signInAccount.put("id", account.getId());
                    signInAccount.put("idToken", account.getIdToken());
                    signInAccount.put("serverAuthCode", account.getServerAuthCode());
                    if (account.getPhotoUrl() != null)
                        signInAccount.put("photoUrl", account.getPhotoUrl().toString());
                }
                return json.toString();
            } catch (JSONException e) {
                Log.e(TAG, "JSON exception", e);
            }
        }
        return new JSONObject().toString();
    }

    @Override
    public void onConnected(android.os.Bundle bundle) {
        // TODO(jackson): implement
        Log.v(TAG, "onConnected");
    }

    @Override
    public void onConnectionSuspended(int cause) {
        // TODO(jackson): implement
        Log.v(TAG, "onConnectionSuspended");
    }

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult result) {
        // TODO(jackson): implement
        Log.v(TAG, "onConnectionFailed");
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == mRequestCode) {
            GoogleSignInResult result = Auth.GoogleSignInApi.getSignInResultFromIntent(data);
            if (mSignInResponse != null) {
                mSignInResponse.send(buildJson(result));
                mSignInResponse = null;
            } else {
                Log.e(TAG, "Unexpected activity result");
            }
        }
    }
}
