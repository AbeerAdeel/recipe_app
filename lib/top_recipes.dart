import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';
import 'package:recipe_app/recipe.dart';
import 'package:intl/intl.dart';

class TopRecipes extends StatefulWidget {
  final String email;
  const TopRecipes({Key key, this.email}) : super(key: key);
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
                  'email': 'adeelabeer@gmail.com',
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
                                    child: RecipeContent(recipe: recipe),
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

class RecipeContent extends StatelessWidget {
  getCleanedDescription(String description) {
    List<String> sentences = description.split(".");
    List<String> cleanedSentences = [];
    for (var sentence in sentences) {
      String cleanedSentence = toBeginningOfSentenceCase(sentence.trim());
      cleanedSentences.add(cleanedSentence);
    }
    return cleanedSentences.join('.  ');
  }

  const RecipeContent({Key key, @required this.recipe})
      : assert(recipe != null),
        super(key: key);
  final dynamic recipe;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle =
        theme.textTheme.headline5.copyWith(color: Colors.white);
    final TextStyle descriptionStyle = theme.textTheme.subtitle1;
    String name = this.recipe['name'].replaceAll('Th', 'th');
    name = name.replaceAll(" S ", "'s ");
    final String description =
        getCleanedDescription(this.recipe['description']);
    final String imageFile = 'assets/' + this.recipe['imageFile'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Photo and title.
        SizedBox(
          height: 184.0,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Ink.image(
                  image: AssetImage(imageFile),
                  fit: BoxFit.cover,
                  child: Container(),
                ),
              ),
              Positioned(
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    name,
                    style: titleStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Description and share/explore buttons.
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
          child: DefaultTextStyle(
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: descriptionStyle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // three line description
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    description,
                    style: descriptionStyle.copyWith(color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_forward),
              color: Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Recipe(
                          id: this.recipe['_id'],
                          name: name,
                          description: description,
                          imageFile: imageFile)),
                );
              },
            )
          ],
        ),
      ],
    );
  }
}
