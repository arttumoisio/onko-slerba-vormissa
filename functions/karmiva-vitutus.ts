import { APIGatewayEvent, Context } from "aws-lambda";
import { headers } from "./call-api/headers";
import { fetchAll, fetchSlerba, fetchWZData } from "./call-api/fetchSlerba";
import { targetPSN } from "../constants/constants";
import { Karmivat } from "./call-api/interfaces";

const API = require("call-of-duty-api")({ platform: "psn" });

export const handler = async (_event: APIGatewayEvent, _context: Context) => {
  const users = _event.multiValueQueryStringParameters?.users || Karmivat;

  try {
    const dataList = await fetchAll(users, API);

    const returnObject: object = dataList.reduce((dict, elem) => {
      return { ...dict, [elem.user]: elem.data };
    }, {});

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
