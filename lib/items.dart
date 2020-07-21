import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';
import 'package:recipe_app/sign_in.dart';
import 'package:recipe_app/favourites.dart';

class ItemsPage extends StatefulWidget {
  ItemsPage({Key key}) : super(key: key);
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final _textFieldController = TextEditingController();
  final GlobalKey<_RenderItemsState> _key = GlobalKey();
  Future<FirebaseUser> _calculation = Future<FirebaseUser>.delayed(
    Duration(seconds: 1),
    () => getCurrentUser(),
  );

  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
        future: _calculation,
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.hasData) {
            return Query(
                options: QueryOptions(
                  documentNode: gql(getCurrentItemsQuery),
                  variables: {
                    'name': snapshot.data.displayName,
                    'email': snapshot.data.email
                  },
                ),
                builder: (QueryResult result,
                    {VoidCallback refetch, FetchMore fetchMore}) {
                  if (result.loading) {
                    print('loading');
                  }
                  return Scaffold(
                    appBar: AppBar(
                      title: Text("Items"),
                      actions: <Widget>[
                        IconButton(
                            icon: Icon(Icons.add),
                            tooltip: 'Add Item',
                            onPressed: () => _displayDialog(context)),
                      ],
                    ),
                    body: Center(
                        child: result.hasException
                            ? Text(result.exception.toString())
                            : result.loading
                                ? CircularProgressIndicator()
                                : RenderItems(
                                    key: _key,
                                    data: result.data['getUserInfo'][0]
                                        ['currentItems'],
                                  )),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FavouritesPage()),
                        );
                      },
                      child: Icon(Icons.local_dining),
                    ),
                  );
                });
          }
          return Container();
        });
  }

  _displayDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
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
                  _key.currentState
                      ._insertSingleItem(_textFieldController.text);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}

class RenderItems extends StatefulWidget {
  final List<dynamic> data;
  const RenderItems({Key key, this.data}) : super(key: key);

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
              _removeSingleItems(index);
            },
          ),
        ),
      ),
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
