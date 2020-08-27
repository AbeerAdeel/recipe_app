import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';
import 'package:recipe_app/graphqlConf.dart';
import 'package:recipe_app/main.dart';
import 'package:recipe_app/top_recipes.dart';
import 'dart:io';

class ItemsPage extends StatefulWidget {
  ItemsPage({Key key, this.email}) : super(key: key);
  final String email;
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final _textFieldController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<dynamic> _items = [];
  String _id;
  AnimationController emptyListController;

  void fillList() async {
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(
      QueryOptions(
        documentNode: gql(getCurrentUserInfo),
        variables: {'email': widget.email},
      ),
    );
    sleep(Duration(microseconds: 10));
    if (this.mounted) {
      setState(() {
        _id = result.data['getUserInfo'][0]['id'];
      });
    }
    for (var i = 0;
        i < result.data['getUserInfo'][0]['currentItems'].length;
        i++) {
      if (this.mounted) {
        setState(() {
          _items.add(result.data['getUserInfo'][0]['currentItems'][i]);
        });
      }
    }
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fillList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Items"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add Item',
            onPressed: () => _displayDialog(context, widget.email),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TopRecipes(
                email: widget.email,
              ),
            ),
          );
        },
        child: Icon(Icons.local_dining),
      ),
      body: Center(
        child: _id == null
            ? CircularProgressIndicator()
            : _items.length == 0
                ? Text('No current items in your fridge or pantree')
                : AnimatedList(
                    key: _listKey,
                    initialItemCount: _items.length,
                    itemBuilder: (context, index, animation) {
                      return _buildItem(
                          context, _items[index], animation, index, _id);
                    },
                  ),
      ),
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
                      'item': _textFieldController.text.toLowerCase(),
                    });
                    _insertSingleItem(_textFieldController.text.toLowerCase());
                    _textFieldController.clear();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildItem(BuildContext context, String item,
      Animation<double> animation, int index, String id) {
    TextStyle textStyle = new TextStyle(fontSize: 20);

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
          axis: Axis.vertical,
          child: Card(
            child: ListTile(
              title: Text(item.toLowerCase(), style: textStyle),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                color: Colors.red,
                onPressed: () {
                  runMutation({'id': id, 'item': item.toLowerCase()});
                  _removeItem(index, id);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _insertSingleItem(item) {
    setState(() {
      _items.insert(0, item);
    });
    if (_listKey.currentState != null) {
      _listKey.currentState.insertItem(0);
    }
  }

  void _removeItem(index, id) {
    String itemToRemove = _items[index];

    _listKey.currentState.removeItem(
      index,
      (BuildContext context, Animation<double> animation) =>
          _buildItem(context, itemToRemove, animation, index, id),
    );

    setState(() {
      _items.removeAt(index);
    });
  }
}
