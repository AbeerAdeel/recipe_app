import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:recipe_app/api.dart';
import 'package:url_launcher/url_launcher.dart';

class Recipe extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final String imageFile;
  final int minutes;
  const Recipe(
      {Key key,
      this.id,
      this.name,
      this.description,
      this.imageFile,
      this.minutes})
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
                imageFile: widget.imageFile,
                minutes: widget.minutes),
            IngredientsTab(id: widget.id),
            StepsTab(id: widget.id),
            NutritionTab(id: widget.id),
            InfoTab(id: widget.id),
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
  final int minutes;
  const HomeTab(
      {Key key, this.name, this.description, this.imageFile, this.minutes})
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
                    "${widget.minutes.toString()} Minutes to Make",
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
          return Center(
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
          return Center(
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

class NutritionTab extends StatefulWidget {
  final String id;
  const NutritionTab({Key key, this.id}) : super(key: key);
  @override
  _NutritionTabState createState() => _NutritionTabState();
}

class _NutritionTabState extends State<NutritionTab> {
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
          documentNode: gql(getRecipeNutrition), variables: {'id': widget.id}),
      builder: (result, {fetchMore, refetch}) {
        if (result.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        Map recipe = result.data['getRecipe'][0];
        return PaginatedDataTable(
          header: Text("Nutrition Facts"),
          rowsPerPage: 6,
          columns: [
            DataColumn(label: Text('')),
            DataColumn(label: Text('')),
          ],
          source: _DataSource(context, recipe['nutrition']),
        );
      },
    );
  }
}

class _Row {
  _Row(
    this.category,
    this.value,
  );
  final String category;
  final dynamic value;
}

class _DataSource extends DataTableSource {
  _DataSource(this.context, this.nutrition) {
    _rows = <_Row>[
      _Row('Calories (g)', this.nutrition[0]),
      _Row('Total Fat (PDV)', this.nutrition[1]),
      _Row('Sugar (PDV)', this.nutrition[2]),
      _Row('Sodium (PDV)', this.nutrition[3]),
      _Row('Protein (PDV)', this.nutrition[4]),
      _Row('Saturated Fat (PDV)', this.nutrition[5]),
    ];
  }
  final BuildContext context;
  List<_Row> _rows;
  List<dynamic> nutrition;

  int _selectedCount = 0;
  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _rows.length) return null;
    final row = _rows[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(row.category)),
        DataCell(Text(row.value.toString())),
      ],
    );
  }

  @override
  int get rowCount => _rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class InfoTab extends StatefulWidget {
  final String id;
  const InfoTab({Key key, this.id}) : super(key: key);
  @override
  _InfoTabState createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
          documentNode: gql(getRecipeInfo), variables: {'id': widget.id}),
      builder: (result, {fetchMore, refetch}) {
        if (result.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        Map recipe = result.data['getRecipe'][0];
        return ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 16, 0.0, 0),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text(
                        'Source',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InkWell(
                        child: Text(
                          recipe['source'],
                          style: TextStyle(color: Colors.blue, fontSize: 14),
                        ),
                        onTap: () => launch(recipe['source']),
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
                        'Recipe Code',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        recipe['recipe_code'].toString(),
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
                        'Contributor ID',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        recipe['contributor_id'].toString(),
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
                        'Date Submitted',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        recipe['submitted'].toString(),
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
      },
    );
  }
}
