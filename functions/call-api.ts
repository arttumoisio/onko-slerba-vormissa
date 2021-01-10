// If you add things to the package.json in this directory, you can magically require them here
// Netlify takes care of all the things
// const axios = require("axios");

import { APIGatewayEvent, Context } from "aws-lambda";

interface WZData {
  matches: WZMatch[];
};

interface WZMatch {
  playerStats: {
    kills: number;
    deaths: number;
  };
  utcStartSeconds: number;
};

const API = require('call-of-duty-api')({ platform: "psn" });
const math = require('core-js/es6/math');

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
const printDebug = (data: {matches: WZMatch[]}) => {
  data.matches.forEach((match: WZMatch)=>{console.log(match.playerStats.kills, match.playerStats.deaths, new Date(match.utcStartSeconds*1000+60*1000*60*2));});
}
export const handler = async (
  event: APIGatewayEvent,
  context: Context
) => {

  try {
    await API.login("aremoro@gmail.com", "wMpab2x7SkybTYk");
    
    let data: WZData = await API.MWcombatwz("slerbatron33#4084536", "acti");
    console.log("Hyvin män");
    
    printDebug(data)

    const tapot: number[] = data.matches.map(match=>match.playerStats.kills).slice(0,5);
    const average: number = countAverage(tapot);

    const kuolemat: number[] = data.matches.map(match=>match.playerStats.deaths).slice(0,5);
    const ratio: number = countRatio(tapot,kuolemat);
    
    return {
      statusCode: 200,
      headers: { 
        "content-type": "application/json; charset=UTF-8",
        "access-control-allow-origin": "*",
        "access-control-expose-headers": "content-encoding,date,server,content-length"
      },
      body: JSON.stringify({
        "vormi": average >= 10 ? "ON VORMI" : "EI OO VORMIA",
        "tapot": tapot,
        "keskiarvo" : average,
        "kd": ratio,
      })
    }
  } catch(Error) {
    console.log("Vituiks män");
    console.log(Error);

    return {
      statusCode: 500,
      body: JSON.stringify({ msg: Error.message }) // Could be a custom message or object i.e. JSON.stringify(err)
    }
  }
};
