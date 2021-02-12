import { password, targetPlatform, username } from "../../constants/constants";
import { WZData, WZMatch, IPalautettava } from "./interfaces";

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

export const fetchWZData = async (
  target: string,
  API: any
): Promise<WZData> => {
  await API.login(username, password);
  console.log("Target", target);

  return API.MWcombatwz(target, targetPlatform);
};

const playedMatch = (match: WZMatch) =>
  !(match.playerStats.kills == 0 && match.playerStats.deaths == 0);

const valueOrZero = (value: number) => (value ? value : 0);
const maxOneOrZero = (value: number) => (value > 1 ? 1 : valueOrZero(value));

export const fetchSlerba = (data: WZData): IPalautettava => {
  const matches = data.matches.filter(playedMatch).slice();

  const tapot: number[] = matches.map((match) =>
    valueOrZero(match.playerStats.kills)
  );

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
  const start: number[] = matches.map((match) => match.utcStartSeconds);
  const end: number[] = matches.map((match) => match.utcEndSeconds);
  const time: number[] = matches.map(
    (match) => match.utcEndSeconds - match.utcStartSeconds
  );

  return {
    tapot,
    kuolemat,
    damaget,
    otetut,
    gulagKills,
    gulagDeaths,
    mode,
    start,
    end,
    time,
  };
};
