import { gql } from "apollo-server-express";

export const typeDefs = gql`
  type Query {
    getTopRecipes(email: String!, limit: Int!, skip: Int!): [Recipe!]!
    getRecipe(id: ID!): [Recipe!]!
    getUserInfo(name: String!, email: String!): [User]!
    getFavouriteRecipes(email: String!, limit: Int!, skip: Int!): [User]!
    getSearchedRecipes(search: String!, limit: Int!, skip: Int!): [Recipe!]!
  }
 type Recipe {
    id: ID
    name: String
    recipe_code: Int
    minutes: Int
    contributor_id: Int
    submitted: String
    tags: [String]
    nutrition: [Float]
    n_steps: Int
    steps: [String]
    description: String
    ingredients: [String]
    n_ingredients: Int
    imageFile: String
    source: String
    order: Int
 },
 type User {
   id: ID,
   name: String
   email: String
   favourites: [ID]
   currentItems: [String]
   favouriteRecipes: [Recipe]
 },
 type Mutation {
    createUser(name: String!, email: String!): User!
    addItem(email: String!, item: String!): User!
    removeItem(id: ID!, item: String!): User!
    addFavourite(email: String!, recipeId: ID!): User!
    removeFavourite(email: String!, recipeId: ID!): User!
  }
`;