import 'package:flutter/material.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';
import 'package:recipe_app/graphqlConf.dart';

class Recipe {
  final String name;
  final String description;

  Recipe(this.name, this.description);
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  Future<List<Recipe>> search(String search) async {
    List<Recipe> recipes = [];
    await Future.delayed(Duration(seconds: 1));
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(
      QueryOptions(
        documentNode: gql(getSearchedRecipes),
        variables: {'search': search, 'skip': 0, 'limit': 5},
      ),
    );

    for (var recipe in result.data['getSearchedRecipes']['recipes']) {
      print(recipe['name']);
      recipes.add(Recipe(recipe['name'], recipe['description']));
    }
    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SearchBar<Recipe>(
            onSearch: search,
            onItemFound: (Recipe post, int index) {
              return ListTile(
                title: Text(post.name),
                subtitle: Text(post.description),
              );
            },
          ),
        ),
      ),
    );
  }
}
