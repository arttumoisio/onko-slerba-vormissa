
const API = require('call-of-duty-api')({ platform: "psn" });

const roundToTwo = (num: number): number => {    
    return +num.toFixed(2);
  };
  
  
  const countRatio = (tapot: number[], kuolemat: number[]): number =>{
    return roundToTwo(
      tapot.reduce((a: number,t: number)=>a+t,0) / kuolemat.reduce((a: number,k: number)=>a+k,0)
    );
  };
  
  const countAverage = (lista: number[]): number =>{
    return roundToTwo(
      lista.reduce((sum, value)=> sum+value,0) / lista.length
    );
  }
  
export const fetchWZData = async(): Promise<WZData> =>{
    await API.login("aremoro@gmail.com", "wMpab2x7SkybTYk");
      
    // return await API.MWcombatwz("kyntö#1293018", "acti");
    return await API.MWcombatwz("slerbatron33#4084536", "acti");
}

export const fetchSlerba = (data: WZData) => { 

    const matches = data.matches.slice(0,5);

    const tapot: number[] = matches.map(match=>match.playerStats.kills);
    const average: number = countAverage(tapot);

    const kuolemat: number[] = matches.map(match=>match.playerStats.deaths);
    const ratio: number = countRatio(tapot,kuolemat);

    return {
        "vormi": average >= 10 ? "ON VORMI" : "EI OO VORMIA",
        "tapot": tapot,
        "kuolemat": kuolemat,
        "keskiarvo" : average,
        "kd": ratio,
      }
  };



  export interface WZData {
    matches: WZMatch[];
  };
  
  export interface WZMatch {
    playerStats: {
      kills: number;
      deaths: number;
    };
    utcStartSeconds: number;
  };