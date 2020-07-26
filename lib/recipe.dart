import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';

class Recipe extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final String imageFile;
  const Recipe({Key key, this.id, this.name, this.description, this.imageFile})
      : super(key: key);
  @override
  _RecipeState createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  final List<Tab> myTabs = <Tab>[
    Tab(text: "Home", icon: Icon(Icons.home)),
    Tab(text: "Ingredients", icon: Icon(Icons.kitchen)),
    Tab(text: "Steps", icon: Icon(Icons.format_list_numbered)),
    Tab(text: "Nutrition Facts", icon: Icon(Icons.fitness_center)),
    Tab(text: "Info", icon: Icon(Icons.info)),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: myTabs,
            isScrollable: true,
          ),
          title: Text(widget.name),
        ),
        body: TabBarView(
          children: [
            RecipeHomePage(
                name: widget.name,
                description: widget.description,
                imageFile: widget.imageFile),
            Icon(Icons.kitchen),
            Icon(Icons.format_list_numbered),
            Icon(Icons.fitness_center),
            Icon(Icons.info),
          ],
        ),
      ),
    );
  }
}

class RecipeHomePage extends StatefulWidget {
  final String name;
  final String description;
  final String imageFile;
  const RecipeHomePage({Key key, this.name, this.description, this.imageFile})
      : super(key: key);
  @override
  _RecipeHomePageState createState() => _RecipeHomePageState();
}

class _RecipeHomePageState extends State<RecipeHomePage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle =
        theme.textTheme.headline5.copyWith(color: Colors.white);
    final TextStyle descriptionStyle = theme.textTheme.subtitle1;
    return ListView(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Photo and title.
        SizedBox(
          height: 184.0,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Ink.image(
                  image: AssetImage(widget.imageFile),
                  fit: BoxFit.cover,
                  child: Container(),
                ),
              ),
              Positioned(
                bottom: 92.0,
                left: 16.0,
                right: 16.0,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    widget.name,
                    style: titleStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Description and share/explore buttons.
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 16, 0.0, 0),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Flexible(
                    child: Text(
                      widget.description,
                      // overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.6), fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 16, 0.0, 0),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Recipe Duration',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Flexible(
                    child: Text(
                      "10 Minutes to Make",
                      // overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.6), fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// return Query(
//       options: QueryOptions(
//           documentNode: gql(getRecipe), variables: {'id': widget.id}),
//       builder: (result, {fetchMore, refetch}) {
//         if (result.loading) {
//           return CircularProgressIndicator();
//         }
//         Map recipe = result.data['getRecipe'][0];
//         return DefaultTabController(
//           length: myTabs.length,
//           child: Scaffold(
//             appBar: AppBar(
//               bottom: TabBar(
//                 tabs: myTabs,
//               ),
//               title: Text(recipe['name']),
//             ),
//             body: TabBarView(
//               children: [
//                 Icon(Icons.home),
//                 Icon(Icons.kitchen),
//                 Icon(Icons.format_list_numbered),
//                 Icon(Icons.fitness_center),
//                 Icon(Icons.info),
//               ],
//             ),
//           ),
//         );
//       },
//     );
