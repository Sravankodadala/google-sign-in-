// Copyright 2016, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library google_sign_in;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'generated/google_sign_in.mojom.dart' as mojom;

export 'generated/google_sign_in.mojom.dart'
  show GoogleSignInUser, GoogleSignInResult;

class _Listener implements mojom.GoogleSignInListener {
  StreamController<mojom.GoogleSignInUser> _streamController;
  _Listener(this._streamController);

  @override
  void onSignIn(mojom.GoogleSignInResult result) {
    if (result.isSuccess) {
      _streamController.add(result.user);
    }
  }

  @override
  void onDisconnected(mojom.GoogleSignInResult result) {
    if (result.isSuccess)
      _streamController.add(null);
  }
}

/// GoogleSignIn allows you to authenticate Google users.
class GoogleSignIn {
  GoogleSignIn(String clientID)
    : _streamController = new StreamController<mojom.GoogleSignInUser>.broadcast(),
      _proxy = new mojom.GoogleSignInProxy.unbound() {
    shell.connectToService("google::GoogleSignIn", _proxy);
    mojom.GoogleSignInListenerStub stub = new mojom.GoogleSignInListenerStub.unbound()
      ..impl = new _Listener(_streamController);
    _proxy.ptr.init(clientID, stub);
    onCurrentUserChanged.listen((mojom.GoogleSignInUser user) => _currentUser = user);
  }

  mojom.GoogleSignInProxy _proxy;
  StreamController<mojom.GoogleSignInUser> _streamController;

  /// Attempts to sign in a previously authenticated user without interaction.
  void signInSilently() => _proxy.ptr.signInSilently();

  /// Starts the sign-in process.
  void signIn() => _proxy.ptr.signIn();

  /// Marks current user as being in the signed out state.
  void signOut() => _proxy.ptr.signOut();

  /// Disconnects the current user from the app and revokes previous authentication.
  void disconnect() => _proxy.ptr.disconnect();

  /// Stream for changes in current user
  Stream<mojom.GoogleSignInUser> get onCurrentUserChanged => _streamController.stream;

  /// Update the requested scopes
  void setScopes(List<String> scopes) => _proxy.ptr.setScopes(scopes);

  /// Read-only access to the current user
  mojom.GoogleSignInUser _currentUser;
  mojom.GoogleSignInUser get currentUser => _currentUser;
}


class GoogleSignInDrawer extends StatefulWidget {
  GoogleSignInDrawer({ this.googleSignIn, this.child }) {
    assert(googleSignIn != null);
    assert(child != null);
  }

  /// The Google Sign-In object to use for this drawer
  final GoogleSignIn googleSignIn;

  /// A widget to display below the drawer header
  ///
  /// Typically a [Block] widget.
  final Widget child;

  @override
  State createState() => new GoogleSignInDrawerState();
}

class GoogleSignInDrawerState extends State<GoogleSignInDrawer> {

  String _coverPhotoUrl;
  StreamSubscription<mojom.GoogleSignInUser> _subscription;
  bool _expanded = false;

  mojom.GoogleSignInUser get _currentUser => config.googleSignIn.currentUser;

  @override
  void initState() {
    if (_currentUser != null)
      _fetchCoverPhotoURL();
    super.initState();
    _subscription = config.googleSignIn.onCurrentUserChanged.listen((_) {
      setState(() {});
      _fetchCoverPhotoURL();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future _fetchCoverPhotoURL() async {
    if (_currentUser == null) {
      _coverPhotoUrl = null;
      return;
    }
    String url = "https://www.googleapis.com/plus/v1/people/${_currentUser.id}?fields=cover";
    Map<String, String> headers = <String, String>{
      'Authorization': 'Bearer ${_currentUser.accessToken}'
    };
    String json = (await http.get(url, headers: headers)).body;
      setState(() {
      _coverPhotoUrl = JSON.decode(json)['cover']['coverPhoto']['url'];
    });
  }

  void _handleTap() {
    print("TAP!");
  }

  @override
  Widget build(BuildContext context) {
    if (config.googleSignIn.currentUser == null)
      return null;
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle nameStyle = textTheme.body2;
    TextStyle emailStyle = textTheme.body1;
    if (_coverPhotoUrl != null) {
      nameStyle = nameStyle.copyWith(color: Colors.white);
      emailStyle = emailStyle.copyWith(color: Colors.white);
    }
    Widget coverPhoto;
    if (_coverPhotoUrl != null)
      coverPhoto = new NetworkImage(src: _coverPhotoUrl);
    return new AccountDrawer(
      coverPhoto: coverPhoto,
      avatar: new NetworkImage(src: config.googleSignIn.currentUser.photoUrl),
      subtitle: new Column(
        children: [
          new Text(_currentUser.displayName, style: nameStyle),
          new Text(_currentUser.email, style: emailStyle),
        ],
        crossAxisAlignment: CrossAxisAlignment.start
      ),
      trailing: new GestureDetector(
        onTap: _handleTap,
        child: new Icon(icon: _expanded ? Icons.expand_more : Icons.expand_less)
      ),
      child: config.child
    );
  }
}
