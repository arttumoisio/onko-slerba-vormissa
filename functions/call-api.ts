import { APIGatewayEvent, Context } from "aws-lambda";
import { headers } from "./call-api/headers";
import { fetchSlerba, fetchWZData } from "./call-api/fetchSlerba";
import { targetPSN } from "../constants/constants";

const API = require("call-of-duty-api")({ platform: "psn" });

export const handler = async (_event: APIGatewayEvent, _context: Context) => {
  const user = _event.queryStringParameters?.user || targetPSN;

  try {
    const data = await fetchWZData(user, API);

    const returnObject = fetchSlerba(data);
    console.log("Hyvin män");
    console.log("User", user);

    return {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(returnObject),
    };
  } catch (Error) {
    console.log("Vituiks män");
    console.log(Error);

    return {
      statusCode: 500,
      body: JSON.stringify({ Error }), // Could be a custom message or object i.e. JSON.stringify(err)
    };
  }
};
