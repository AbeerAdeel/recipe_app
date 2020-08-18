import 'package:recipe_app/items.dart';
import 'package:recipe_app/login.dart';
import 'package:recipe_app/search.dart';
import 'package:recipe_app/favourites.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/sign_in.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key key, @required this.email, @required this.name})
      : assert(name != null),
        super(key: key);
  final String email;
  final String name;
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 0;

  void onTappedBar(int index) {
    if (index == 3) {
      signOutGoogle();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      ItemsPage(email: widget.email, name: widget.name),
      SearchPage(email: widget.email, name: widget.name),
      FavouritesPage(email: widget.email),
      LoginPage(),
    ];
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: onTappedBar,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            title: Text('Items'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            title: Text('Favourites'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
            title: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
