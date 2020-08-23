import express from "express";
import mongoose from "mongoose";
import { ApolloServer } from "apollo-server-express";
import { resolvers } from "./resolvers";
import { typeDefs } from "./models/typeDefs";

const startServer = async () => {
    const app = express();

    const server = new ApolloServer({
        typeDefs,
        resolvers,
        playground: true
    });

    server.applyMiddleware({ app });

    await mongoose.connect('mongodb+srv://aadeel:Andrew12@cluster0-frt96.mongodb.net/Recipe_Dataset?retryWrites=true&w=majority', {
        useNewUrlParser: true,
        useUnifiedTopology: true
    });

    app.listen({port: process.env.PORT || 5000}, () =>
        console.log(`Server ready at http://localhost:5000${server.graphqlPath}`)
    );
}

startServer();