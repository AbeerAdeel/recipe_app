import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';
import 'package:recipe_app/navbar.dart';
import 'package:recipe_app/login.dart';
import 'package:recipe_app/sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Future<FirebaseUser> _calculation = Future<FirebaseUser>.delayed(
    Duration(seconds: 1),
    () => getCurrentUser(),
  );
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      child: FutureBuilder<FirebaseUser>(
        future: _calculation,
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          Widget children = Container();
          if (snapshot.hasData) {
            children = NavBar(
                email: snapshot.data.email, name: snapshot.data.displayName);
          } else {
            children = LoginPage();
          }
          return MaterialApp(title: 'Recipes', home: children);
        },
      ),
      client: client,
    );
  }
}
