import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';

class ItemsPage extends StatefulWidget {
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          documentNode: gql(getTopRecipesQuery),
          variables: {
            'currentIngredients': ["beef", "sugar", "pumpkin"],
            'skip': 3,
            'limit': 5
          },
        ),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Items"),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                  tooltip: 'Add Item',
                  onPressed: () {
                    print('Add Item');
                  },
                ),
              ],
            ),
            body: Center(
                child: result.hasException
                    ? Text(result.exception.toString())
                    : result.loading
                        ? CircularProgressIndicator()
                        : RenderItems(
                            list: result.data['getTopRecipes'],
                            onRefresh: refetch)),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                print('hello');
              },
              child: Icon(Icons.local_dining),
            ),
          );
        });
  }
}

class RenderItems extends StatelessWidget {
  RenderItems({@required this.list, @required this.onRefresh});
  final list;
  final onRefresh;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: this.list.length,
        itemBuilder: (context, index) {
          final recipe = this.list[index];
          return ListTile(title: Text(recipe['name']));
        });
  }
}
