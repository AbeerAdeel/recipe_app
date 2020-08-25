import 'dart:io';
import 'package:recipe_app/graphqlConf.dart';
import 'package:recipe_app/recipe.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';
import 'package:recipe_app/image_item.dart';

class RecipeContent extends StatefulWidget {
  const RecipeContent({Key key, this.recipe, this.email}) : super(key: key);
  final dynamic recipe;
  final String email;
  @override
  _RecipeContentState createState() => _RecipeContentState();
}

class _RecipeContentState extends State<RecipeContent> {
  List<dynamic> _favourites = [];
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();

  getCleanedDescription(String description) {
    List<String> sentences = description.split(".");
    List<String> cleanedSentences = [];
    for (var sentence in sentences) {
      String cleanedSentence = toBeginningOfSentenceCase(sentence.trim());
      cleanedSentences.add(cleanedSentence);
    }
    return cleanedSentences.join('.  ');
  }

  void fillList() async {
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(
      QueryOptions(
        documentNode: gql(getCurrentUserInfo),
        variables: {'email': widget.email},
      ),
    );
    sleep(Duration(microseconds: 10));
    for (var i = 0;
        i < result.data['getUserInfo'][0]['favourites'].length;
        i++) {
      if (this.mounted) {
        setState(() {
          _favourites.add(result.data['getUserInfo'][0]['favourites'][i]);
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fillList();
  }

  @override
  Widget build(BuildContext context) {
    final String id = widget.recipe['id'];
    final alreadyLiked = _favourites.contains(id);
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle =
        theme.textTheme.headline5.copyWith(color: Colors.white);
    final TextStyle descriptionStyle = theme.textTheme.subtitle1;
    String name = widget.recipe['name'].replaceAll('Th', 'th');
    name = name.replaceAll(" S ", "'s ");
    final String description =
        getCleanedDescription(widget.recipe['description']);
    final String imageFile = widget.recipe['imageFile'] != null
        ? widget.recipe['imageFile']
        : 'placeholder.png';

    return Mutation(
      options: MutationOptions(
        documentNode: alreadyLiked ? gql(removeFavourite) : gql(addFavourite),
      ),
      builder: (RunMutation runMutation, QueryResult result) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Photo and title.
            SizedBox(
              height: 184.0,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: ImageItem(
                      imageFile: imageFile,
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
              alignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: alreadyLiked
                      ? Icon(Icons.favorite)
                      : Icon(Icons.favorite_border),
                  color: Colors.blue,
                  onPressed: () {
                    setState(
                      () {
                        if (alreadyLiked) {
                          _favourites.remove(id);
                          runMutation({'email': widget.email, 'recipeId': id});
                        } else {
                          _favourites.add(id);
                          runMutation({'email': widget.email, 'recipeId': id});
                        }
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Recipe(
                          id: widget.recipe['id'],
                          name: name,
                          description: description,
                          imageFile: imageFile,
                          minutes: widget.recipe['minutes'],
                          favourites: _favourites,
                          email: widget.email,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
