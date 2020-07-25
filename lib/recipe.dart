import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';

class Recipe extends StatefulWidget {
  final String id;
  const Recipe({Key key, this.id}) : super(key: key);
  @override
  _RecipeState createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  final List<Tab> myTabs = <Tab>[
    Tab(icon: Icon(Icons.home)),
    Tab(icon: Icon(Icons.kitchen)),
    Tab(icon: Icon(Icons.format_list_numbered)),
    Tab(icon: Icon(Icons.fitness_center)),
    Tab(icon: Icon(Icons.info)),
  ];

  @override
  Widget build(BuildContext context) {
    print(widget.id);
    return Query(
      options: QueryOptions(
          documentNode: gql(getRecipe), variables: {'id': widget.id}),
      builder: (result, {fetchMore, refetch}) {
        if (result.loading) {
          return CircularProgressIndicator();
        }
        Map recipe = result.data['getRecipe'][0];
        return DefaultTabController(
          length: myTabs.length,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: myTabs,
              ),
              title: Text(recipe['name']),
            ),
            body: TabBarView(
              children: [
                Icon(Icons.home),
                Icon(Icons.kitchen),
                Icon(Icons.format_list_numbered),
                Icon(Icons.fitness_center),
                Icon(Icons.info),
              ],
            ),
          ),
        );
      },
    );
  }
}
