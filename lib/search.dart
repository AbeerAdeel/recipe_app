import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';
import 'package:recipe_app/recipe_content.dart';

class Recipe {
  final String name;
  final String description;
  final String imageFile;
  final String id;
  final int minutes;

  Recipe(this.name, this.description, this.imageFile, this.id, this.minutes);
}

class SearchPage extends StatefulWidget {
  SearchPage({Key key, this.email}) : super(key: key);
  final String email;
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller;
  ShapeBorder shape;
  String text = "";

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int skip = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Search'),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Search for recipe',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (String value) {
                    if (this.mounted) {
                      this.setState(() {
                        text = value;
                      });
                    }
                  },
                ),
              ),
              Query(
                options: QueryOptions(
                  documentNode: gql(getSearchedRecipes),
                  variables: {
                    'search': text,
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

                  if (result.loading) {
                    skip = skip + 5;
                  }

                  final repositories =
                      (result.data['getSearchedRecipes'] as List<dynamic>);

                  // final favourites =
                  //     result.data['getSearchedRecipes']['favourites'];

                  final opts = FetchMoreOptions(
                    variables: {'skip': skip},
                    updateQuery: (previousResultData, fetchMoreResultData) {
                      final repos = [
                        ...previousResultData['getSearchedRecipes'],
                        ...fetchMoreResultData['getSearchedRecipes']
                      ];
                      fetchMoreResultData['getSearchedRecipes'] = repos;
                      return fetchMoreResultData;
                    },
                  );

                  if (repositories.length == 0) {
                    return Center(
                      child: Text("Could not get any search results"),
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
                            // skip = skip + 5;
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
        ));
  }
}
