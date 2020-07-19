import * as mongoose from "mongoose";

export const Recipe = mongoose.model('Recipe', {
     name: String,
     recipe_code: Number,
     minutes: Number,
     contributor_id: Number,
     submitted: String,
     tags: Array,
     nutrition: Array,
     n_steps: Number,
     steps: Array,
     description: String,
     ingredients: Array,
     n_ingredients: Number,
     imageFile: String,
     source: String
});