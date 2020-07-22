import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';

class TopRecipes extends StatefulWidget {
  final String email;
  const TopRecipes({Key key, this.email}) : super(key: key);
  @override
  _TopRecipesState createState() => _TopRecipesState();
}

class _TopRecipesState extends State<TopRecipes> {
  ShapeBorder shape;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recommended Recipes"),
      ),
      body: Center(
          child: Query(
        options: QueryOptions(
            documentNode: gql(getTopRecipesQuery),
            variables: {'email': widget.email, 'skip': 0, 'limit': 5}),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.loading) {
            return CircularProgressIndicator();
          } else {
            List recipes = result.data['getTopRecipes'];
            return ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return SafeArea(
                    top: false,
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 338.0,
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
                  );
                });
          }
        },
      )),
    );
  }
}

class RecipeContent extends StatelessWidget {
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
    final String name = this.recipe['name'];
    final String description = this.recipe['description'];
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
                // Text(destination.city),
                // Text(destination.location),
              ],
            ),
          ),
        ),

        // share, explore buttons
        ButtonBar(
          alignment: MainAxisAlignment.start,
          children: <Widget>[
            FlatButton(
              child: Text('SHARE', semanticsLabel: 'Share ${name}'),
              textColor: Colors.amber.shade500,
              onPressed: () {
                print('pressed');
              },
            ),
            FlatButton(
              child: Text('EXPLORE', semanticsLabel: 'Explore ${name}'),
              textColor: Colors.amber.shade500,
              onPressed: () {
                print('pressed');
              },
            ),
          ],
        ),
      ],
    );
  }
}
