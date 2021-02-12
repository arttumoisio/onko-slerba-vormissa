import { APIGatewayEvent, Context } from "aws-lambda";
import { headers } from "./call-api/headers";
import { targetPSN } from "../constants/constants";
import { run } from "./mongoUtil/storeMongoSlerba";

export const handler = async (_event: APIGatewayEvent, _context: Context) => {
  process.env.MONGO_URL && run();

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
