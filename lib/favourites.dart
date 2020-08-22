import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';
import 'package:recipe_app/recipe_content.dart';

class FavouritesPage extends StatefulWidget {
  FavouritesPage({Key key, this.email}) : super(key: key);
  final String email;
  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  int get count => list.length;
  ShapeBorder shape;
  List<dynamic> list = [];
  int skip = 5;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favourites"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Query(
              options: QueryOptions(
                documentNode: gql(getFavouriteRecipes),
                variables: {
                  'email': widget.email,
                  'skip': 0,
                  'limit': 5,
                },
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

                final repositories = (result.data['getFavouriteRecipes'][0]
                    ['favouriteRecipes'] as List<dynamic>);

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

                if (repositories.length == 0) {
                  return Center(
                    child: Text('No current favourite recipes'),
                  );
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
                                      email: widget.email,
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
}
