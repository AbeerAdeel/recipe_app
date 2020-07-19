import { Recipe } from './models/recipe';

export const resolvers = {
    Query: {
        getTopRecipes: async (_, { currentIngredients, skip, limit }) => {
            return await Recipe.find({
                $and: [
                    { ingredients: { $in: currentIngredients } },
                    { imageFile: { $exists: true } }
                ]
            }).limit(limit).skip(skip)
        },
        getRecipe: async (_, { id }) => {
            return await Recipe.find({ _id: id });
        },
    }
}
