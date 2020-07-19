import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';
import 'package:recipe_app/navbar.dart';
import 'package:recipe_app/login.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Future<bool> _calculation = Future<bool>.delayed(
    Duration(seconds: 1),
    () => _googleSignIn.isSignedIn(),
  );
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      child: FutureBuilder<bool>(
        future: _calculation,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          Widget children = LoginPage();
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              children = NavBar();
            }
          }
          return MaterialApp(title: 'Recipes', home: children);
        },
      ),
      client: client,
    );
  }
}
