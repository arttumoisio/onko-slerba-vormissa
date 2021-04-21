import { APIGatewayEvent, Context } from "aws-lambda";
import { headers } from "./call-api/headers";
import {
  WZDataToIPalautettava,
  fetchWZData,
  WZDataToPalautettavaMatchList,
} from "./call-api/fetchSlerba";
import { targetPSN } from "../constants/constants";
import { storeSlerba } from "./redisUtil/storeRedisSlerba";
import { fetchAllAsMatchList } from "./call-api/fetchAll";

const API = require("call-of-duty-api")({ platform: "psn" });

export const handler = async (_event: APIGatewayEvent, _context: Context) => {
  const users = _event.multiValueQueryStringParameters?.users || ["nepagell"];
  try {
    const data = await fetchAllAsMatchList(users, API);

    const returnData = data.map((userWithList) => {
      const user = userWithList.user;
      console.log("storing", user);
      return storeSlerba(userWithList);
    });

    console.log("Hyvin män");
    console.log("Users:", users);

    // const returnObj: object = returnData.reduce((dict, elem) => {
    //   return { ...dict, [elem.user]: elem.data };
    // }, {});
    
    returnData.

    return {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(await returnData),
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
