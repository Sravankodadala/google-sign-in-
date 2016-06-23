// Copyright 2016, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(
    new MaterialApp(
      title: 'Google Sign In',
      home: new SignInDemo()
    )
  );
}

class SignInDemo extends StatefulWidget {
  @override
  State createState() => new SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount _currentUser;

  @override
  void initState() {
    super.initState();
    GoogleSignIn.signInSilently().then(_handleGoogleSignInResult);
  }

  void _handleGoogleSignInResult(GoogleSignInResult result) {
    setState(() => _currentUser = result.signInAccount);
  }

  Future<Null> _handleSignIn() async {
    GoogleSignIn.signIn().then(_handleGoogleSignInResult);
  }

  void _handleSignOut() {
    GoogleSignIn.disconnect().then(_handleGoogleSignInResult);
  }

  Widget _buildBody() {
    if (_currentUser != null) {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new ListItem(
            leading: new CircleAvatar(
              child: new ClipOval(
                child: new Image(image: new NetworkImage(_currentUser.photoUrl))
              )
            ),
            title: new Text(_currentUser.displayName),
            subtitle: new Text(_currentUser.email)
          ),
          new RaisedButton(
            child: new Text('SIGN OUT'),
            onPressed: _handleSignOut
          )
        ]
      );
    } else {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Text("You are not currently signed in."),
          new RaisedButton(
            child: new Text('SIGN IN'),
            onPressed: _handleSignIn
          )
        ]
      );
    }
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Google Sign In')
      ),
      body: _buildBody()
    );
  }
}
