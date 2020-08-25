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

// import 'package:flutter/material.dart';

// class AnimatedListExample extends StatefulWidget {
//   @override
//   AnimatedListExampleState createState() {
//     return new AnimatedListExampleState();
//   }
// }

// class AnimatedListExampleState extends State<AnimatedListExample> {
//   final GlobalKey<AnimatedListState> _listKey = GlobalKey();

//   List<String> _data = ["apples", "peaches", "oranges"];

//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       appBar: new AppBar(
//         title: new Text('Animated List'),
//         backgroundColor: Colors.blueAccent,
//       ),
//       persistentFooterButtons: <Widget>[
//         RaisedButton(
//           child: Text(
//             'Add an item',
//             style: TextStyle(fontSize: 20, color: Colors.white),
//           ),
//           onPressed: () {
//             _addAnItem();
//           },
//         ),
//         RaisedButton(
//           child: Text(
//             'Remove last',
//             style: TextStyle(fontSize: 20, color: Colors.white),
//           ),
//           onPressed: () {
//             _removeLastItem();
//           },
//         ),
//         RaisedButton(
//           child: Text(
//             'Remove all',
//             style: TextStyle(fontSize: 20, color: Colors.white),
//           ),
//           onPressed: () {
//             _removeAllItems();
//           },
//         ),
//       ],
//       body: AnimatedList(
//         key: _listKey,
//         initialItemCount: _data.length,
//         itemBuilder: (context, index, animation) =>
//             _buildItem(context, _data[index], animation),
//       ),
//     );
//   }

//   Widget _buildItem(
//       BuildContext context, String item, Animation<double> animation) {
//     TextStyle textStyle = new TextStyle(fontSize: 20);

//     return Padding(
//       padding: const EdgeInsets.all(2.0),
//       child: SizeTransition(
//         sizeFactor: animation,
//         axis: Axis.vertical,
//         child: SizedBox(
//           height: 50.0,
//           child: Card(
//             child: Center(
//               child: Text(item, style: textStyle),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _addAnItem() {
//     _data.insert(0, "abeer");
//     _listKey.currentState.insertItem(0);
//   }

//   void _removeLastItem() {
//     String itemToRemove = _data[0];

//     _listKey.currentState.removeItem(
//       0,
//       (BuildContext context, Animation<double> animation) =>
//           _buildItem(context, itemToRemove, animation),
//       duration: const Duration(milliseconds: 250),
//     );

//     _data.removeAt(0);
//   }

//   void _removeAllItems() {
//     final int itemCount = _data.length;

//     for (var i = 0; i < itemCount; i++) {
//       String itemToRemove = _data[0];
//       _listKey.currentState.removeItem(
//         0,
//         (BuildContext context, Animation<double> animation) =>
//             _buildItem(context, itemToRemove, animation),
//         duration: const Duration(milliseconds: 250),
//       );

//       _data.removeAt(0);
//     }
//   }
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'ListView Example',
//       home: AnimatedListExample(),
//     );
//   }
// }

// void main() => runApp(MyApp());
