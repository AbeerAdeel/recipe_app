import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/graphqlConf.dart';
import 'package:recipe_app/navbar.dart';
import 'package:recipe_app/login.dart';
import 'package:recipe_app/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:splashscreen/splashscreen.dart';

GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      child: MaterialApp(
        title: 'Recipes',
        home: SplashScreen(
            seconds: 2,
            navigateAfterSeconds:
                MaterialApp(title: 'Recipes', home: AfterSplash()),
            image: Image(
              image: AssetImage('assets/splash.png'),
              alignment: Alignment.center,
            ),
            backgroundColor: Colors.blue,
            photoSize: 100,
            loaderColor: Colors.blue),
      ),
      client: graphQLConfiguration.client,
    );
  }
}

class AfterSplash extends StatelessWidget {
  Future<FirebaseUser> _calculation = Future<FirebaseUser>.delayed(
    Duration(seconds: 2),
    () => getCurrentUser(),
  );
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
      future: _calculation,
      builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
        if (snapshot.hasData) {
          return NavBar(
              email: snapshot.data.email, name: snapshot.data.displayName);
        } else {
          return LoginPage();
        }
      },
    );
  }
}
