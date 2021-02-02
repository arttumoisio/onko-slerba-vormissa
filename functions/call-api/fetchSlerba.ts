const API = require("call-of-duty-api")({ platform: "psn" });

import { WZData, WZMatch } from "./interfaces";

const roundToTwo = (num: number): number => {
  return +num.toFixed(2);
};

const password = process.env.password || "wMpab2x7SkybTYk";
const username = process.env.username || "aremoro@gmail.com";
const targetPlatform = process.env.targetPlatform || "acti";
const targetPSN = process.env.targetPSN || "slerbatron33#4084536";
// const targetPSN = "kyntö#1293018";
// const targetPSN = "kupperi";

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

export const fetchWZData = async (): Promise<WZData> => {
  await API.login(username, password);
  console.log(targetPSN);

  return await API.MWcombatwz(targetPSN, targetPlatform);
};

const playedMatch = (match: WZMatch) => {
  console.log(
    "Kills and deaths:",
    match.playerStats.kills,
    match.playerStats.deaths
  );
  return !(match.playerStats.kills == 0 && match.playerStats.deaths == 0);
};

const valueOrZero = (value: number) => (value ? value : 0);
const maxOneOrZero = (value: number) => {
  const retVal = value > 1 ? 1 : valueOrZero(value);
  console.log("val:", value, "ret:", retVal);
  return retVal;
};
export const fetchSlerba = (data: WZData) => {
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
  console.log(" ");

  const gulagDeaths: number[] = matches.map((match) =>
    maxOneOrZero(match.playerStats.gulagDeaths)
  );

  const mode: string[] = matches.map((match) => match.mode);

  const posi: number[] = matches.map((match) => valueOrZero(match.player.rank));
  console.log(posi);
  const posiP: number[] = matches.map((match) =>
    valueOrZero(match.playerStats.rank)
  );
  console.log(posiP);

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
    posiP,
    posi,
  };
};
