// Copyright 2016, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library google_sign_in;

import 'dart:async';

import 'package:flutter/services.dart';

class GoogleSignInAccount {
  final String displayName;
  final String email;
  final String id;
  final String idToken;
  final String serverAuthCode;
  final String photoUrl;

  GoogleSignInAccount._(Map<String, dynamic> message)
    : displayName = message['displayName'],
      email = message['email'],
      id = message['id'],
      idToken = message['idToken'],
      serverAuthCode = message['serverAuthCode'],
      photoUrl = message['photoUrl'];
}

class GoogleSignInResult {
  final bool isSuccess;
  final GoogleSignInAccount signInAccount;

  GoogleSignInResult._(Map<String, dynamic> message)
    : isSuccess = message['isSuccess'],
      signInAccount = message['signInAccount'] != null ?
                        new GoogleSignInAccount._(message['signInAccount']) :
                        null;
}

/// GoogleSignIn allows you to authenticate Google users.
class GoogleSignIn {

  static Future<GoogleSignInResult> _callMethod(String method) async {
    Map<String, String> request = <String, String>{'method': method};
    Map<String, dynamic> response = await HostMessages.sendJSON('GoogleSignIn', request);
    return new GoogleSignInResult._(response);
  }

  /// Attempts to sign in a previously authenticated user without interaction.
  static Future<GoogleSignInResult> signInSilently() => _callMethod('signInSilently');

  /// Starts the sign-in process.
  static Future<GoogleSignInResult> signIn() => _callMethod('signIn');

  /// Marks current user as being in the signed out state.
  static Future<GoogleSignInResult> signOut() => _callMethod('signOut');

  /// Disconnects the current user from the app and revokes previous authentication.
  static Future<GoogleSignInResult> disconnect() => _callMethod('disconnect');
}
