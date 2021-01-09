// If you add things to the package.json in this directory, you can magically require them here
// Netlify takes care of all the things
// const axios = require("axios");

exports.handler = function(event, context, callback) {

  const vormiTapot = [
    12,
    14,
    1,
    1,
    33,
  ];
  const paskaVormiTapot = [
    1,
    3,
    1,
    6,
    7,
  ];
  
  const palautettava = Date.now() % 2 == 1 ? vormiTapot : paskaVormiTapot;
  const average = palautettava.reduce((sum, value)=> sum+value,0) / palautettava.length;

  return callback(null, {
    statusCode: 200,
    headers: { 
      "content-type": "application/json; charset=UTF-8",
      "access-control-allow-origin": "*",
      "access-control-expose-headers": "content-encoding,date,server,content-length"
    },
    body: JSON.stringify({
      "vormi": average >= 10 ? "ON VORMI" : "EI OO VORMIA",
      "tapot": palautettava,
      "keskiarvo" : average
    })
  })
} 