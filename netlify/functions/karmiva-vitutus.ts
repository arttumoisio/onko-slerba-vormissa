import { Handler } from "@netlify/functions";

import { headers } from "../call-api/headers";
import { Karmivat } from "../call-api/interfaces";
import { fetchAll } from "../call-api/fetchAll";

export const handler: Handler = async (event, context) => {
  const users = event.multiValueQueryStringParameters?.users || Karmivat;

  try {
    const dataList = await fetchAll(users);

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
