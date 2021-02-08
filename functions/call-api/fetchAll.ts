import { storeSlerba } from "../redisUtil/storeSlerba";
import { fetchSlerba, fetchWZData } from "./fetchSlerba";
import { NimettyPalautettava } from "./interfaces";

const asyncFetchWZDataAndFormat = async (
  user: string,
  API: any
): Promise<NimettyPalautettava> => {
  return fetchWZData(user, API).then((data) => {
    const returnObject = { user, data: fetchSlerba(data) };
    storeSlerba(returnObject);
    return returnObject;
  });
};

export const fetchAll = async (arrayOfUsers: string[], API: any) => {
  return Promise.all(
    arrayOfUsers.map((user) => asyncFetchWZDataAndFormat(user, API))
  );
};
