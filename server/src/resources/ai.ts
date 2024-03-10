import { config } from "../config";
import { complete } from "../third/openai";
import { getEventTypes } from "./eventTypes";
// import { complete3 } from "../third/openai";
// import { mutateEvents } from "./events";
import { getEvents, mutateEvents } from "./events";
// import { getTags } from "./tags";
import * as fs from 'fs';


export async function convertMessageToEvent(instruction: string, message: string, time: string, returnGqlOnly: boolean = false) {
    const events = await getEvents({user_id: 1});
    const event_types =  await getEventTypes();
    // const tags = await getTags();
    let prompt = instruction
    prompt += "Using the above instruction return to me json with gql and reasoning"
    prompt += "\n"
    prompt += JSON.stringify({
        message,
        time,
        user_id: 1,
        recent_events: events,
        event_types
    });

    
    
    
    let response = await complete(prompt)
    console.log(response);
    if(!returnGqlOnly)        
        await mutateEvents(JSON.parse(response).gql);

    let dataToWrite = "input: \n" + JSON.stringify({
        message,
        time,
        user_id: 1,
        recent_events: events,
        event_types
    }, null, 2); // The '2' argument here adds indentation for readability
    dataToWrite += "\noutput:\n" + printGQL(JSON.parse(response).gql);
    if(config.testing)
      fs.writeFileSync("./specs/current.txt", dataToWrite);

    return response
}


export function printGQL(mutation: string) {
    // return "test"
    // Split the mutation into lines based on specific characters
    const parts = mutation.split(/({|}|\[|\])/);
    let indent = 0;
    let formattedMutation = '';
  
    parts.forEach(part => {
      if (part === '{' || part === '[') {
        // Increase indent and add line break
        formattedMutation += part + '\n' + '  '.repeat(++indent);
      } else if (part === '}' || part === ']') {
        // Decrease indent, add line break and current bracket
        formattedMutation += '\n' + '  '.repeat(--indent) + part;
      } else {
        // Handle the case of commas separating objects or fields
        const trimmedPart = part.trim();
        if (trimmedPart) {
          // Split by commas not within quotes
          const subParts = trimmedPart.split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/);
          subParts.forEach((subPart, index) => {
            formattedMutation += subPart.trim();
            if (index < subParts.length - 1) { // If not the last subPart, add a comma and line break
              formattedMutation += ',\n' + '  '.repeat(indent);
            }
          });
        }
      }
    });
    return formattedMutation;
  }
  
//   const mutationString = `mutation insert_event { insert_events(objects: [{user_id: 1, event_type: "sleep", status: "doing", start_time: "2024-03-08T22:32:44-08:00", end_time: null}]) { affected_rows } }`;
  

  