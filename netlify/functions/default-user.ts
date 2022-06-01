import { Handler } from "@netlify/functions";

import { headers } from "../call-api/headers";
import { targetPSN } from "../../constants/constants";

export const handler: Handler = async (event, context) => {
  try {
    return {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(targetPSN),
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
