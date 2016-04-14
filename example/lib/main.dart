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
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => new SignInDemo()
      }
    )
  );
}

class SignInDemo extends StatefulWidget {
  @override
  State createState() => new SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  // Update this string with your app's client id
  static const String _kClientId = "946753052256-j58q7kn21j491vfn5m5v56bblgcpevgg.apps.googleusercontent.com";

  GoogleSignIn _gsi;
  GoogleSignInUser _currentUser;

  @override
  void initState() {
    super.initState();
    _gsi = new GoogleSignIn(_kClientId)
      ..onCurrentUserChanged.listen((GoogleSignInUser user) {
        setState(() => _currentUser = user);
      })
      ..signInSilently();
  }

  Widget _buildBody() {
    if (_currentUser == null) {
      return new Column(
        children: <Widget>[
          new Text("You are not currently signed in."),
          new RaisedButton(
            child: new Text('SIGN IN'),
            onPressed: _gsi.signIn
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceAround
      );
    } else {
      return new Column(
        children: <Widget>[
          new ListItem(
            leading: new CircleAvatar(
              child: new ClipOval(
                child: new NetworkImage(src: _currentUser.photoUrl)
              )
            ),
            title: new Text(_currentUser.displayName),
            subtitle: new Text(_currentUser.email)
          ),
          new RaisedButton(
            child: new Text('SIGN OUT'),
            onPressed: _gsi.disconnect
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceAround
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
