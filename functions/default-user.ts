import { APIGatewayEvent, Context } from "aws-lambda";
import { headers } from "./call-api/headers";
import { targetPSN } from "./call-api/constants";

export const handler = async (_event: APIGatewayEvent, _context: Context) => {
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
