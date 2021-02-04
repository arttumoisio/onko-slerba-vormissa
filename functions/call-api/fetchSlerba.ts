const API = require("call-of-duty-api")({ platform: "psn" });

import { password, targetPlatform, targetPSN, username } from "./constants";
import { IAvailableUsers, WZData, WZMatch } from "./interfaces";

const roundToTwo = (num: number): number => {
  return +num.toFixed(2);
};

const countRatio = (tapot: number[], kuolemat: number[]) => {
  return roundToTwo(
    tapot.reduce((a, t) => a + t, 0) / kuolemat.reduce((a, k) => a + k, 0)
  );
};

const countAverage = (lista: number[]) => {
  return roundToTwo(
    lista.reduce((sum, value) => sum + value, 0) / lista.length
  );
};

export const fetchWZData = async (target: string): Promise<WZData> => {
  await API.login(username, password);
  console.log("Target", target);

  return await API.MWcombatwz(target, targetPlatform);
};

const playedMatch = (match: WZMatch) =>
  !(match.playerStats.kills == 0 && match.playerStats.deaths == 0);

const valueOrZero = (value: number) => (value ? value : 0);
const maxOneOrZero = (value: number) => {
  const retVal = value > 1 ? 1 : valueOrZero(value);
  console.log("val:", value, "ret:", retVal);
  return retVal;
};

export const fetchSlerba = (data: WZData, target: string) => {
  const matches = data.matches.filter(playedMatch).slice();

  console.log(Object.keys(data.summary));

  const tapot: number[] = matches.map((match) =>
    valueOrZero(match.playerStats.kills)
  );
  const keskiarvo: number = countAverage(tapot);

  const kuolemat: number[] = matches.map((match) =>
    valueOrZero(match.playerStats.deaths)
  );
  const kd: number = countRatio(tapot, kuolemat);

  const damaget: number[] = matches.map((match) =>
    valueOrZero(match.playerStats.damageDone)
  );
  const otetut: number[] = matches.map((match) =>
    valueOrZero(match.playerStats.damageTaken)
  );

  const gulagKills: number[] = matches.map((match) =>
    maxOneOrZero(match.playerStats.gulagKills)
  );

  const gulagDeaths: number[] = matches.map((match) =>
    maxOneOrZero(match.playerStats.gulagDeaths)
  );

  const mode: string[] = matches.map((match) => match.mode);

  return {
    vormi: keskiarvo >= 10 ? "ON VORMI" : "EI OO VORMIA",
    tapot,
    kuolemat,
    keskiarvo,
    kd,
    damaget,
    otetut,
    gulagKills,
    gulagDeaths,
    mode,
    user: target,
    defaultUser: targetPSN,
  };
};
