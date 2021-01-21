import { APIGatewayEvent, Context } from "aws-lambda";
import { headers } from "./call-api/headers";
import { fetchSlerba, fetchWZData } from "./call-api/fetchSlerba";
import { printDebug } from "./call-api/debugger";


export const handler = async (
  event: APIGatewayEvent,
  context: Context
) => {

  try {
    const data = await fetchWZData();
    console.log("Hyvin män");
    
    printDebug(data);
    const returnObject = fetchSlerba(data);
    console.log(returnObject);
    

    return {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(returnObject)
    }
  } catch(Error) {
    console.log("Vituiks män");
    console.log(Error);

    return {
      statusCode: 500,
      body: JSON.stringify({ Error }) // Could be a custom message or object i.e. JSON.stringify(err)
    }
  }
};
