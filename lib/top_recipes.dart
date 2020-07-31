import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';
import 'package:recipe_app/recipe_content.dart';

class TopRecipes extends StatefulWidget {
  final String email;
  final List<dynamic> favourites;
  const TopRecipes({Key key, this.email, this.favourites}) : super(key: key);
  @override
  _TopRecipesState createState() => _TopRecipesState();
}

class _TopRecipesState extends State<TopRecipes> {
  int get count => list.length;
  ShapeBorder shape;
  List<dynamic> list = [];
  int skip = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recommended Recipes"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Query(
              options: QueryOptions(
                documentNode: gql(getTopRecipesQuery),
                variables: {
                  'email': widget.email,
                  'skip': 0,
                  'limit': 5,
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
                final repositories =
                    (result.data['getTopRecipes'] as List<dynamic>);

                final opts = FetchMoreOptions(
                  variables: {'skip': skip},
                  updateQuery: (previousResultData, fetchMoreResultData) {
                    final repos = [
                      ...previousResultData['getTopRecipes'],
                      ...fetchMoreResultData['getTopRecipes']
                    ];
                    fetchMoreResultData['getTopRecipes'] = repos;
                    return fetchMoreResultData;
                  },
                );

                if (result.loading) {
                  skip = skip + 5;
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
                                      favourites: widget.favourites,
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
