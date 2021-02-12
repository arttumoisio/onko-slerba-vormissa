"use strict";

import { NimettyPalautettava } from "functions/call-api/interfaces";
import redis from "redis";
import { MongoClient } from "mongodb";

const MONGO_URL = process.env.MONGO_URL;
const MONGO_PASSWORD = process.env.MONGO_PASSWORD;
const MONGO_USERNAME = process.env.MONGO_USERNAME;
const MONGO_DBNAME = process.env.MONGO_DBNAME;

// Replace the following with your Atlas connection string
const url = `mongodb+srv://${MONGO_USERNAME}:${MONGO_PASSWORD}@${MONGO_URL}/${MONGO_DBNAME}?retryWrites=true&w=majority`;

const client = new MongoClient(url, { useNewUrlParser: true });

export const run = async () => {
  try {
    await client.connect((err) => {
      const collection = client.db(MONGO_DBNAME).collection("devices");
      console.log(collection);

      // perform actions on the collection object
    });
    console.log("Connected correctly to server");
  } catch (err) {
    console.log(err.stack);
  } finally {
    await client.close();
  }
};
