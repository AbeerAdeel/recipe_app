import { Recipe } from './models/recipe';
import { User } from './models/user';

export const resolvers = {
    Query: {
        getTopRecipes: async (_, { email, skip, limit }) => {
            const user = await User.find({ email });
            if (!user) {
                throw new Error("Can't find user");
            }
            const currentItems = user[0].currentItems;
            return await Recipe.find({
                $and: [
                    { ingredients: { $in: currentItems } },
                    { imageFile: { $exists: true } }
                ]
            }).limit(limit).skip(skip)
        },
        getRecipe: async (_, { id }) => {
            return await Recipe.find({ _id: id });
        },
        getUserInfo: async (_, { name, email }) => {
            return await User.find({name, email});
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
        },
        addItem: async (_, {email, item }) => {
            const user = await User.find({ email});
            if (!user) {
                throw new Error("User doesn't exist");
            }
            await User.update({ email }, { $push: { currentItems: item }});
            const updatedUser = await User.find({ email });
            return updatedUser[0];
        },
        removeItem: async (_, { _id, item }) => {
            const user = await User.find({ _id });
            if (!user) {
                throw new Error("User doesn't exist");
            }
            await User.update({ _id }, { $pull: { currentItems: item } });
            const updatedUser = await User.find({ _id });
            return updatedUser[0];
        },
    }
}
