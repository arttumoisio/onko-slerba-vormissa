import { WZMatch } from "./interfaces";

export const printDebug = (data: {matches: WZMatch[]}) => {
    data.matches.forEach((match: WZMatch)=>{
      console.log(match.playerStats.kills, match.playerStats.deaths, new Date(match.utcStartSeconds*1000+60*1000*60*2));});
}