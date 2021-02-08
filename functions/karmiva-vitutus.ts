import { APIGatewayEvent, Context } from "aws-lambda";
import { headers } from "./call-api/headers";
import { Karmivat } from "./call-api/interfaces";
import { fetchAll } from "./call-api/fetchAll";

const API = require("call-of-duty-api")();

export const handler = async (_event: APIGatewayEvent, _context: Context) => {
  const users = _event.multiValueQueryStringParameters?.users || Karmivat;

  try {
    const dataList = await fetchAll(users, API);

    const returnArray: object = dataList.reduce((dict, elem) => {
      return { ...dict, [elem.user]: elem.data };
    }, {});

    return {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(returnArray),
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
