import { mapData, fetchWZData } from "./fetchSlerba";
import { NimettyPalautettava } from "./interfaces";

const fetchAndFormatWZData = async (
  user: string
): Promise<NimettyPalautettava> => {
  return fetchWZData(user).then((data) => ({ user, data: mapData(data) }));
};

export const fetchAll = async (users: string[]) => {
  const promises = users.map((user) => fetchAndFormatWZData(user));
  return Promise.all(promises);
};
