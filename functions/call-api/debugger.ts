import { WZData } from "./interfaces";

export const printDebug = (data: WZData) => {
  data.matches.forEach((match) => {
    console.log(
      match.playerStats.kills,
      match.playerStats.deaths,
      new Date(match.utcStartSeconds * 1000 + 60 * 1000 * 60 * 2)
    );
  });
};
