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

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key key,
    this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // String _searchQuery = 'flutter';
  // int nRepositories = 10;

  // void changeQuery(String query) {
  //   setState(() {
  //     print(query);
  //     _searchQuery = query ?? 'flutter';
  //   });
  // }
  int skip = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            // TextField(
            //   decoration: const InputDecoration(
            //     labelText: 'Search Query',
            //   ),
            //   keyboardType: TextInputType.text,
            //   onSubmitted: changeQuery,
            // ),
            Query(
              options: QueryOptions(
                documentNode: gql(getTopRecipesQuery),
                variables: {
                  'email': 'adeelabeer@gmail.com',
                  'skip': skip,
                  'limit': 1,
                },
                //pollInterval: 10,
              ),
              builder: (QueryResult result, {refetch, FetchMore fetchMore}) {
                if (result.hasException) {
                  return Text(result.exception.toString());
                }

                if (result.loading && result.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (result.data == null && !result.hasException) {
                  return const Text(
                      'Both data and errors are null, this is a known bug after refactoring, you might have forgotten to set Github token');
                }

                // result.data can be either a [List<dynamic>] or a [Map<String, dynamic>]
                print(result.data);
                final repositories =
                    (result.data['getTopRecipes'] as List<dynamic>);
                skip = skip + 1;
                final opts = FetchMoreOptions(
                  variables: {'skip': skip},
                  updateQuery: (previousResultData, fetchMoreResultData) {
                    final repos = [
                      ...previousResultData['getTopRecipes'],
                      ...fetchMoreResultData['getTopRecipes']
                    ];

                    print(repos);
                    fetchMoreResultData['getTopRecipes'] = repos;
                    return fetchMoreResultData;
                  },
                );
                // print(repositories);
                return Expanded(
                  child: ListView(
                    children: <Widget>[
                      for (var repository in repositories)
                        ListTile(
                          // leading: (repository['viewerHasStarred'] as bool)
                          //     ? const Icon(
                          //         Icons.star,
                          //         color: Colors.amber,
                          //       )
                          //     : const Icon(Icons.star_border),
                          title: Text(repository['name'] as String),
                        ),
                      if (result.loading)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                          ],
                        ),
                      RaisedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Load More'),
                          ],
                        ),
                        onPressed: () {
                          fetchMore(opts);
                        },
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
