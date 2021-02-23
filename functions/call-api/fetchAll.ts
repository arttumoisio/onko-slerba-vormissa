import { storeSlerba } from "../redisUtil/storeRedisSlerba";
import { fetchSlerba, fetchWZData } from "./fetchSlerba";
import { NimettyPalautettava } from "./interfaces";

const asyncFetchWZDataAndFormat = async (
  user: string,
  API: any
): Promise<NimettyPalautettava> => {
  return fetchWZData(user, API).then((data) => {
    console.log("Fetching", user);
    const returnObject = { user, data: fetchSlerba(data) };
    console.log("storing", user);

    storeSlerba(returnObject);
    console.log("Returning", user);

    return returnObject;
  });
};

export const fetchAll = async (arrayOfUsers: string[], API: any) => {
  return Promise.all(
    arrayOfUsers.map((user) => asyncFetchWZDataAndFormat(user, API))
  );
};
