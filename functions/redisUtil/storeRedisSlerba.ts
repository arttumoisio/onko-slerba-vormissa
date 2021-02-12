import { NimettyPalautettava } from "functions/call-api/interfaces";
import redis from "redis";

const REDIS_PORT = process.env.REDIS_PORT;
const REDIS_URL = process.env.REDIS_URL;
const REDIS_PASSWORD = process.env.REDIS_PASSWORD;

const REDIS_USERDATA_PREFIX = "userdata.";

const client = redis.createClient(Number(REDIS_PORT), REDIS_URL, {
  password: REDIS_PASSWORD,
});

client.on("error", (err) => {
  console.log("Error " + err);
});

export const storeSlerba = async (data: NimettyPalautettava) => {
  console.log(`Trying to store ${data.user}'s data to redis`);
  client.set(
    REDIS_USERDATA_PREFIX + data.user,
    JSON.stringify(data.data),
    (err, reply) => {
      if (err) throw err;
      console.log(data.user, " set reply:", reply);

      client.get(REDIS_USERDATA_PREFIX + data.user, (err, reply) => {
        if (err) throw err;
        if (reply) {
          console.log(
            data.user,
            " get reply:",
            Object.keys(JSON.parse(reply)).length
          );
        }
      });
    }
  );
};
