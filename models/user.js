import * as mongoose from "mongoose";

export const User = mongoose.model('User', {
    name: String,
    email: String,
    currentItems: Array,
    favourites: Array
});