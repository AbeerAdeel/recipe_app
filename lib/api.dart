import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
    cache: InMemoryCache(),
    link: HttpLink(uri: 'http://192.168.2.133:5000/graphql'),
  ),
);

final String getTopRecipesQuery = """
  query TopRecipes(\$email: String!, \$skip: Int!, \$limit: Int!) {
      getTopRecipes(email: \$email, skip: \$skip, limit: \$limit) {
        _id
        name
        description
        imageFile
      }
    }
""";

final String getCurrentItemsQuery = """
  query CurrentItems(\$name: String!, \$email: String!) {
      getUserInfo(name: \$name, email: \$email) {
        _id
        name
        email
        currentItems
      }
    }
""";

final String createUser = """
  mutation CreateUser(\$name: String!, \$email: String!) {
    createUser(name: \$name, email: \$email) {
      _id
      name
      email
    }
  }
""";

final String addItem = """
  mutation AddItem(\$email: String!, \$item: String!) {
    addItem(email: \$email, item: \$item) {
      _id
      name
      email
      currentItems
    }
  }
""";

final String removeItem = """
  mutation RemoveItem(\$_id: ID!, \$item: String!) {
    removeItem(_id: \$_id, item: \$item) {
      _id
      name
      email
      currentItems
    }
  }
""";
