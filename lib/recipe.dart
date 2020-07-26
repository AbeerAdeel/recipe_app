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
            HomeTab(
                name: widget.name,
                description: widget.description,
                imageFile: widget.imageFile),
            IngredientsTab(id: widget.id),
            StepsTab(id: widget.id),
            Icon(Icons.fitness_center),
            Icon(Icons.info),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  final String name;
  final String description;
  final String imageFile;
  const HomeTab({Key key, this.name, this.description, this.imageFile})
      : super(key: key);
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
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
                  child: Text(
                    widget.description,
                    // overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.6), fontSize: 14),
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
                  child: Text(
                    "10 Minutes to Make",
                    // overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.6), fontSize: 14),
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

class IngredientsTab extends StatefulWidget {
  final String id;
  const IngredientsTab({Key key, this.id}) : super(key: key);
  @override
  _IngredientsTabState createState() => _IngredientsTabState();
}

class _IngredientsTabState extends State<IngredientsTab> {
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
          documentNode: gql(getRecipeIngredients),
          variables: {'id': widget.id}),
      builder: (result, {fetchMore, refetch}) {
        if (result.loading) {
          return Container(
            child: CircularProgressIndicator(),
          );
        }
        Map recipe = result.data['getRecipe'][0];
        return ListView(
          children: [
            for (var ingredient in recipe['ingredients'])
              ListTile(
                title: Text(ingredient
                    .split(' ')
                    .map((word) => word[0].toUpperCase() + word.substring(1))
                    .join(' ')),
                leading: Icon(Icons.arrow_forward),
                // trailing: Text("0$count"),
              ),
          ],
        );
      },
    );
  }
}

class StepsTab extends StatefulWidget {
  final String id;
  const StepsTab({Key key, this.id}) : super(key: key);
  @override
  _StepsTabState createState() => _StepsTabState();
}

class _StepsTabState extends State<StepsTab> {
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
          documentNode: gql(getRecipeSteps), variables: {'id': widget.id}),
      builder: (result, {fetchMore, refetch}) {
        if (result.loading) {
          return Container(
            child: CircularProgressIndicator(),
          );
        }
        Map recipe = result.data['getRecipe'][0];
        return Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 10, 0.0, 0),
          child: ListView(
            children: [
              for (var i = 0; i < recipe['steps'].length; i++)
                ListTile(
                  title: Text(
                      "${recipe['steps'][i][0].toUpperCase() + recipe['steps'][i].substring(1)}"),
                  leading: Text("${(i + 1).toString()}."),
                  // trailing: Text("0$count"),
                ),
            ],
          ),
        );
      },
    );
  }
}
