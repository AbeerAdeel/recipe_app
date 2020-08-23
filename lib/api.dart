final String getTopRecipesQuery = """
  query TopRecipes(\$email: String!, \$skip: Int!, \$limit: Int!) {
      getTopRecipes(email: \$email, skip: \$skip, limit: \$limit) {
        id
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
        id
        favourites
        favouriteRecipes {
          id
          name
          description
          imageFile
          minutes
        }
      }
    }
""";

final String getCurrentUserInfo = """
  query CurrentItems(\$email: String!) {
      getUserInfo(email: \$email) {
        id
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
      id
      name
      email
    }
  }
""";

final String addItem = """
  mutation AddItem(\$email: String!, \$item: String!) {
    addItem(email: \$email, item: \$item) {
      id
      name
      email
      currentItems
    }
  }
""";

final String removeItem = """
  mutation RemoveItem(\$id: ID!, \$item: String!) {
    removeItem(id: \$id, item: \$item) {
      id
      name
      email
      currentItems
    }
  }
""";

final String addFavourite = """
  mutation AddFavourite(\$email: String!, \$recipeId: ID!) {
    addFavourite(email: \$email, recipeId: \$recipeId) {
      id
      name
      email
      favourites
    }
  }
""";

final String removeFavourite = """
  mutation RemoveFavourite(\$email: String!, \$recipeId: ID!) {
    removeFavourite(email: \$email, recipeId: \$recipeId) {
      id
      name
      email
      favourites
    }
  }
""";

final String getRecipeIngredients = """
  query GetRecipe(\$id: ID!) {
      getRecipe(id: \$id) {
        id
        ingredients
      }
    }
""";

final String getRecipeSteps = """
  query GetRecipe(\$id: ID!) {
      getRecipe(id: \$id) {
        id
        steps
      }
    }
""";

final String getRecipeNutrition = """
  query GetRecipe(\$id: ID!) {
      getRecipe(id: \$id) {
        id
        nutrition
      }
    }
""";

final String getRecipeInfo = """
  query GetRecipe(\$id: ID!) {
      getRecipe(id: \$id) {
        id
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
          id
          name
          description
          imageFile
          minutes
      }
    }
""";
