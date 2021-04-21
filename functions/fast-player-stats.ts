import { APIGatewayEvent, Context } from "aws-lambda";
import { headers } from "./call-api/headers";
import { getAllFast } from "./redisUtil/getRedisSlerba";

const API = require("call-of-duty-api")({ platform: "psn" });

export const handler = async (_event: APIGatewayEvent, _context: Context) => {
  const users = _event.multiValueQueryStringParameters?.users || ["nepagell"];
  try {
    const data = await getAllFast(users);

    console.log("Hyvin män");
    console.log("Users:", users);

    const returnObj: object = data.reduce((dict, elem) => {
      return { ...dict, [elem.user]: elem.data };
    }, {});

    return {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(returnObj),
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
