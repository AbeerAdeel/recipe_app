import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';
import 'package:recipe_app/sign_in.dart';
import 'package:recipe_app/top_recipes.dart';

class ItemsPage extends StatefulWidget {
  ItemsPage({Key key, this.email, this.name}) : super(key: key);
  final String email;
  final String name;
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final _textFieldController = TextEditingController();
  final GlobalKey<_RenderItemsState> _key = GlobalKey();
  // Future<FirebaseUser> _calculation = Future<FirebaseUser>.delayed(
  //   Duration(seconds: 1),
  //   () => getCurrentUser(),
  // );

  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        documentNode: gql(getCurrentUserInfo),
        variables: {'name': widget.name, 'email': widget.email},
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
                  onPressed: () => _displayDialog(context, widget.email)),
            ],
          ),
          body: Center(
              child: result.hasException
                  ? Text(result.exception.toString())
                  : result.loading
                      ? CircularProgressIndicator()
                      : RenderItems(
                          key: _key,
                          data: result.data['getUserInfo'][0]['currentItems'],
                          id: result.data['getUserInfo'][0]['id'])),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TopRecipes(
                        email: widget.email,
                        favourites: result.data['getUserInfo'][0]
                            ['favourites'])),
              );
            },
            child: Icon(Icons.local_dining),
          ),
        );
      },
    );
  }

  _displayDialog(BuildContext context, String email) {
    return showDialog(
        context: context,
        builder: (context) {
          return Mutation(
            options: MutationOptions(
              documentNode: gql(addItem),
            ),
            builder: (
              RunMutation runMutation,
              QueryResult result,
            ) {
              return AlertDialog(
                title: Text('Add an Item'),
                content: TextField(
                  controller: _textFieldController,
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('ADD'),
                    onPressed: () {
                      runMutation({
                        'email': email,
                        'item': _textFieldController.text,
                      });
                      _key.currentState
                          ._insertSingleItem(_textFieldController.text);
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        });
  }
}

class RenderItems extends StatefulWidget {
  final List<dynamic> data;
  final String id;
  const RenderItems({Key key, this.data, this.id}) : super(key: key);

  @override
  _RenderItemsState createState() => _RenderItemsState();
}

class _RenderItemsState extends State<RenderItems> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return AnimatedList(
        key: _listKey,
        initialItemCount: widget.data.length,
        itemBuilder: (context, index, animation) {
          return _buildItem(widget.data[index], animation, index);
        });
  }

  Widget _buildItem(String item, Animation animation, int index) {
    return Mutation(
      options: MutationOptions(
        documentNode: gql(removeItem),
      ),
      builder: (
        RunMutation runMutation,
        QueryResult result,
      ) {
        return SizeTransition(
          sizeFactor: animation,
          child: Card(
            child: ListTile(
              title: Text(
                item,
                style: TextStyle(fontSize: 20),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                color: Colors.red,
                onPressed: () {
                  runMutation({'id': widget.id, 'item': item});
                  _removeSingleItems(index);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _insertSingleItem(item) {
    int insertIndex = widget.data.length;
    widget.data.insert(insertIndex, item);
    _listKey.currentState.insertItem(insertIndex);
  }

  void _removeSingleItems(removeIndex) {
    String removedItem = widget.data.removeAt(removeIndex);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return _buildItem(removedItem, animation, removeIndex);
    };
    _listKey.currentState.removeItem(removeIndex, builder);
  }
}
