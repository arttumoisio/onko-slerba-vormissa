
const API = require('call-of-duty-api')({ platform: "psn" });

import { WZData } from "./interfaces";

const roundToTwo = (num: number): number => {    
    return +num.toFixed(2);
};

const password = process.env.password || "wMpab2x7SkybTYk";
const username = process.env.username || "aremoro@gmail.com";
const targetPSN = process.env.targetPSN || "slerbatron33#4084536";
  
const countRatio = (tapot: number[], kuolemat: number[]) =>{
  return roundToTwo(
    tapot.reduce((a,t)=>a+t,0) / kuolemat.reduce((a,k)=>a+k,0)
  );
};
  
const countAverage = (lista: number[]) =>{
  return roundToTwo(
    lista.reduce((sum, value)=> sum+value,0) / lista.length
  );
}
  
export const fetchWZData = async(): Promise<WZData> =>{
    await API.login(username, password);
      
    // return await API.MWcombatwz("kyntö#1293018", "acti");
    return await API.MWcombatwz(targetPSN, "acti");
}

export const fetchSlerba = (data: WZData) => { 
    
    const matches = data.matches.slice();

    const tapot: number[] = matches.map(match=>match.playerStats.kills);
    const average: number = countAverage(tapot);

    const kuolemat: number[] = matches.map(match=>match.playerStats.deaths);
    const ratio: number = countRatio(tapot,kuolemat);
    
    const damaget: number[] = matches.map(match=>match.playerStats.damageDone);
    const otetut: number[] = matches.map(match=>match.playerStats.damageTaken);

    const gulagKills: number[] = matches.map(match=>match.playerStats.gulagKills);
    const gulagDeaths: number[] = matches.map(match=>match.playerStats.gulagDeaths);

    return {
        vormi: average >= 10 ? "ON VORMI" : "EI OO VORMIA",
        tapot,
        kuolemat,
        keskiarvo : average,
        kd: ratio,
        damaget,
        otetut,
        gulagKills,
        gulagDeaths,
      }
};
