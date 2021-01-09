// If you add things to the package.json in this directory, you can magically require them here
// Netlify takes care of all the things
// const axios = require("axios");
const API = require('call-of-duty-api')({ platform: "psn" });



exports.handler = async (event, context, callback) => {

  
  try {
    await API.login("aremoro@gmail.com", "wMpab2x7SkybTYk");
    
    let data = await API.MWcombatwz("slerbatron33#4084536", "acti");
    console.log("Hyvin män");
    data.matches.forEach((match)=>{console.log(match.playerStats.kills, new Date(match.utcStartSeconds*1000+60*1000*60*2));});

    const tapot = data.matches.map(match=>match.playerStats.kills).slice(0,5);
    const average = tapot.reduce((sum, value)=> sum+value,0) / tapot.length;
    return callback(null, {
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
        "slerba": data.matches,
      })
    })
  } catch(Error) {
    console.log("Vituiks män");
    console.log(Error);

    return {
      statusCode: 500,
      body: JSON.stringify({ msg: Error.message }) // Could be a custom message or object i.e. JSON.stringify(err)
    }
  }
  
  
} 