import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';
import 'package:recipe_app/sign_in.dart';
import 'package:recipe_app/navbar.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.local_dining,
                size: 150,
                color: Colors.blue,
              ),
              SizedBox(height: 50),
              _signInButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return Mutation(
        options: MutationOptions(
          documentNode: gql(createUser),
        ),
        builder: (
          RunMutation runMutation,
          QueryResult result,
        ) {
          return OutlineButton(
            splashColor: Colors.grey,
            onPressed: () {
              signInWithGoogle().whenComplete(() async {
                FirebaseUser user = await getCurrentUser();
                runMutation({'name': user.displayName, 'email': user.email});
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return NavBar(email: user.email, name: user.displayName);
                    },
                  ),
                );
              });
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            highlightElevation: 0,
            borderSide: BorderSide(color: Colors.grey),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                      image: AssetImage("assets/google_logo.png"),
                      height: 35.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
