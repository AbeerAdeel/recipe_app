import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';
import 'package:recipe_app/sign_in.dart';
import 'package:recipe_app/recipe_content.dart';

class FavouritesPage extends StatefulWidget {
  FavouritesPage({Key key}) : super(key: key);
  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  int get count => list.length;
  ShapeBorder shape;
  List<dynamic> list = [];
  int skip = 5;
  Future<FirebaseUser> _calculation = Future<FirebaseUser>.delayed(
    Duration(seconds: 1),
    () => getCurrentUser(),
  );
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
      future: _calculation,
      builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Favourites"),
            ),
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Query(
                    options: QueryOptions(
                      documentNode: gql(getFavouriteRecipes),
                      variables: {
                        'email': snapshot.data.email,
                        'skip': 0,
                        'limit': 5,
                      },
                    ),
                    builder: (QueryResult result,
                        {refetch, FetchMore fetchMore}) {
                      if (result.hasException) {
                        return Text(result.exception.toString());
                      }

                      if (result.loading && result.data == null) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      print(result.data);
                      final repositories = (result.data['getFavouriteRecipes']
                          [0]['favouriteRecipes'] as List<dynamic>);

                      final opts = FetchMoreOptions(
                        variables: {'skip': skip},
                        updateQuery: (previousResultData, fetchMoreResultData) {
                          final repos = [
                            ...previousResultData['getFavouriteRecipes'][0]
                                ['favouriteRecipes'],
                            ...fetchMoreResultData['getFavouriteRecipes'][0]
                                ['favouriteRecipes']
                          ];
                          fetchMoreResultData['getFavouriteRecipes'][0]
                              ['favouriteRecipes'] = repos;
                          return fetchMoreResultData;
                        },
                      );

                      if (result.loading) {
                        skip = skip + 5;
                      }
                      List<dynamic> favourites = List();
                      for (var recipe in repositories) {
                        favourites.add(recipe["_id"]);
                      }
                      return Expanded(
                        child: ListView(
                          children: <Widget>[
                            for (var recipe in repositories)
                              SafeArea(
                                top: false,
                                bottom: false,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 320.0,
                                        child: Card(
                                          // This ensures that the Card's children are clipped correctly.
                                          clipBehavior: Clip.antiAlias,
                                          shape: shape,
                                          child: RecipeContent(
                                            recipe: recipe,
                                            favourites: favourites,
                                            email: snapshot.data.email,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
        return Container();
      },
    );
  }
}
