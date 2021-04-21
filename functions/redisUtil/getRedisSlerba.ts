import {
  IPalautettava,
  IPalautusMatch,
  NimettyMatchList,
  NimettyPalautettava,
} from "functions/call-api/interfaces";
import redis from "redis";

const REDIS_PORT = process.env.REDIS_PORT;
const REDIS_URL = process.env.REDIS_URL;
const REDIS_PASSWORD = process.env.REDIS_PASSWORD;
const REDIS_URI = process.env.REDIS_URI || "";

const REDIS_USERDATA_PREFIX = "userdata.";

const client = redis.createClient(REDIS_URI);

client.on("error", (err) => {
  console.log("Error " + err);
});

const mergeDataOnStartTime = (
  oldData: IPalautusMatch[],
  newData: IPalautusMatch[]
) => {
  const lastStartTime = oldData.reduce(
    (prevMax, elem) => (elem.start > prevMax ? elem.start : prevMax),
    0
  );
  const newMatches = newData.filter(({ start }) => start > lastStartTime);
  return [...oldData].concat(newMatches);
};

export const getSlerba = async (user: string): Promise<NimettyMatchList> =>
  new Promise((resolve, reject) => {
    console.log(`Trying to get ${user}'s data from redis`);
    try {
      client.get(REDIS_USERDATA_PREFIX + user, (err, reply) => {
        if (err) {
          reject(err);
        }
        if (reply) {
          console.log(user, reply);

          const data: IPalautusMatch[] = JSON.parse(reply);

          resolve({ user, data });
        }
        client.quit();
      });
    } catch (err) {
      reject(err);
    }
  });

export const getAllFast = async (users: string[]) =>
  Promise.all(users.map((user) => getSlerba(user)));
