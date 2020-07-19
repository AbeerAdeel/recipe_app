import { gql } from "apollo-server-express";

export const typeDefs = gql`
  type Query {
    getTopRecipes(currentIngredients: [String]!, limit: Int!, skip: Int!): [Recipe!]!
    getRecipe(id: ID!): [Recipe!]!
  }
 type Recipe {
    _id: ID!
    name: String!
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
 },
`;