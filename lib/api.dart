import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
    cache: InMemoryCache(),
    link: HttpLink(uri: 'http://192.168.2.133:5000/graphql'),
  ),
);

final String getTopRecipesQuery = """
  query TopRecipes(\$currentIngredients: [String]!, \$skip: Int!, \$limit: Int!) {
      getTopRecipes(currentIngredients: \$currentIngredients, skip: \$skip, limit: \$limit) {
        _id
        name
      }
    }
""";
