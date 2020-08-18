import { Recipe } from './models/recipe';
import { User } from './models/user';
import mongoose from "mongoose";

export const resolvers = {
    Query: {
        getTopRecipes: async (_, { email, skip, limit }) => {
            const user = await User.find({ email });
            if (!user) {
                throw new Error("Can't find user");
            }
            const currentItems = user[0].currentItems;
            return await Recipe.aggregate([
                { $match: { ingredients: { $in: currentItems } } },
                { $match: { imageFile: { $exists: true } } },
                {
                    $project: {
                        id: "$_id",
                        name: 1,
                        description: 1,
                        imageFile: 1,
                        minutes: 1,
                        order: {
                            $size: {
                                $setIntersection: [currentItems, "$ingredients"]
                            }
                        }
                    }
                },
                { $sort: { order: -1, description: -1 } },
                { $skip: skip },
                { $limit: limit },
            ]);
        },
        getRecipe: async (_, { id }) => {
            return await Recipe.find({ _id: id });
        },
        getUserInfo: async (_, { name, email }) => {
            return await User.find({ name, email });
        },
        getSearchedRecipes: async (_, { search, limit, skip, email}) => {
            const recipes = await Recipe.find({ name: { $regex: search, $options: "i" } }).limit(limit).skip(skip);
            const user = await User.find({ email });
            const favourites = user[0]['favourites'];
            console.log(favourites);
            return { recipes, favourites };
        },
        getFavouriteRecipes: async (_, { email, limit, skip }) => {
            const user = await User.find({ email });
            if (!user) {
                throw new Error("User doesn't exist");
            }
            const favouriteQuery = [
                {
                    $match: {
                        email: email,
                    }
                },
                {
                    $lookup: {
                        from: "recipes",
                        let: { favourite_ids: "$favourites"},
                        pipeline: [
                            {
                                $match: {
                                    $expr: {$in: ["$_id", "$$favourite_ids"]}
                                }
                            },
                            {
                                $project: {
                                    id: "$_id",
                                    name: 1,
                                    description: 1,
                                    imageFile: 1,
                                    minutes: 1
                                }
                            },
                            { $skip: skip},
                            { $limit: limit },
                            
                        ],
                        as: "favouriteRecipes",
                    }
                },
                {
                    $project: {
                        id: "$_id",
                        favourites: 1,
                        favouriteRecipes: 1,
                    }
                },
            ];
            return await User.aggregate(favouriteQuery);
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
        addItem: async (_, { email, item }) => {
            const user = await User.find({ email });
            if (!user) {
                throw new Error("User doesn't exist");
            }
            await User.update({ email }, { $push: { currentItems: item } });
            const updatedUser = await User.find({ email });
            return updatedUser[0];
        },
        removeItem: async (_, { id, item }) => {
            const user = await User.find({ id });
            if (!user) {
                throw new Error("User doesn't exist");
            }
            await User.update({ id }, { $pull: { currentItems: item } });
            const updatedUser = await User.find({ id });
            return updatedUser[0];
        },
        addFavourite: async (_, { email, recipeId }) => {
            const recipe = await Recipe.find({ id: recipeId });
            if (!recipe) {
                throw new Error("Recipe doesn't exist");
            }
            const user = await User.find({ email });
            if (!user) {
                throw new Error("User doesn't exist");
            }
            await User.update({ email }, { $push: { favourites: mongoose.Types.ObjectId(recipeId) } });
            const updatedUser = await User.find({ email });
            return updatedUser[0];
        },
        removeFavourite: async (_, { email, recipeId }) => {
            const recipe = await Recipe.find({ id: recipeId });
            if (!recipe) {
                throw new Error("Recipe doesn't exist");
            }
            const user = await User.find({ email });
            if (!user) {
                throw new Error("User doesn't exist");
            }
            await User.update({ email }, { $pull: { favourites: mongoose.Types.ObjectId(recipeId) } });
            const updatedUser = await User.find({ email });
            return updatedUser[0];
        },
    }
}
