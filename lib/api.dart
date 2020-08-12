final String getTopRecipesQuery = """
  query TopRecipes(\$email: String!, \$skip: Int!, \$limit: Int!) {
      getTopRecipes(email: \$email, skip: \$skip, limit: \$limit) {
        _id
        name
        description
        imageFile
        minutes
      }
    }
""";

final String getFavouriteRecipes = """
  query FavouriteRecipes(\$email: String!, \$skip: Int!, \$limit: Int!) {
      getFavouriteRecipes(email: \$email, skip: \$skip, limit: \$limit) {
        _id
        favourites
        favouriteRecipes {
          _id
          name
          description
          imageFile
          minutes
        }
      }
    }
""";

final String getCurrentUserInfo = """
  query CurrentItems(\$name: String!, \$email: String!) {
      getUserInfo(name: \$name, email: \$email) {
        _id
        name
        email
        currentItems
        favourites
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

final String addFavourite = """
  mutation AddFavourite(\$email: String!, \$recipeId: ID!) {
    addFavourite(email: \$email, recipeId: \$recipeId) {
      _id
      name
      email
      favourites
    }
  }
""";

final String removeFavourite = """
  mutation RemoveFavourite(\$email: String!, \$recipeId: ID!) {
    removeFavourite(email: \$email, recipeId: \$recipeId) {
      _id
      name
      email
      favourites
    }
  }
""";

final String getRecipeIngredients = """
  query GetRecipe(\$id: ID!) {
      getRecipe(id: \$id) {
        _id
        ingredients
      }
    }
""";

final String getRecipeSteps = """
  query GetRecipe(\$id: ID!) {
      getRecipe(id: \$id) {
        _id
        steps
      }
    }
""";

final String getRecipeNutrition = """
  query GetRecipe(\$id: ID!) {
      getRecipe(id: \$id) {
        _id
        nutrition
      }
    }
""";

final String getRecipeInfo = """
  query GetRecipe(\$id: ID!) {
      getRecipe(id: \$id) {
        _id
        source
        recipe_code
        contributor_id
        submitted
      }
    }
""";

final String getSearchedRecipes = """
  query GetSearchedRecipes(\$search: String!, \$limit: Int!, \$skip: Int!) {
      getSearchedRecipes(search: \$search, limit: \$limit, skip: \$skip) {
        recipes {
          _id
          name
          description
          imageFile
        }
        count
      }
    }
""";
