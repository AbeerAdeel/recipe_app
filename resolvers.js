import { Recipe } from './models/recipe';
import { User } from './models/user';

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
    },
    Mutation: {
        createUser: async (_, { name, email }) => {
            const checkUser = await User.find({ name, email });
            if (checkUser.length > 0) {
                console.log("User exists already");
                return checkUser[0];
            }
            const user = new User({ name, email });
            console.log("Sucesfully created user");
            await user.save();
            return user
        }
    }
}
