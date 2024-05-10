// import Replicate from "replicate";
import { config } from "../config";
// const replicate = new Replicate({
//     auth: config.replicateApiKey
// });

import Groq from "groq-sdk";

const groq = new Groq(
    {
        apiKey:config.groqApiKey

    }
)
interface CompleteOptions {
    temperature?: number,
    max_tokens?: number,
    toLowerCase?: boolean
    model?: "8b" | "70b"
}
export async function llamaComplete(prompt: string, completeOptions?: CompleteOptions): Promise<string> {
    let startTime = Date.now();
    let r = await groq.chat.completions.create({
        messages: [
            {
                role: "user",
                content: prompt
            }
        ],
        model: completeOptions?.model == "70b" ? "llama3-70b-8192" : "llama3-8b-8192",
      
      max_tokens: completeOptions?.max_tokens,
      temperature: completeOptions?.temperature
    });
    let endTime = Date.now();
    // console.log(`Time taken: ${endTime - startTime}ms`);
    // console.log(r.usage)
    let message =  r.choices[0].message.content
    return completeOptions?.toLowerCase ? message.toLocaleLowerCase() : message
}

export function extractJson(jsonString: string): any {
    let firstCurlyIndex = jsonString.indexOf('{');
    let firstSquareIndex = jsonString.indexOf('[');

    // Determine which bracket comes first (if any) and set appropriate start and end characters
    let startChar = (firstSquareIndex !== -1 && (firstSquareIndex < firstCurlyIndex || firstCurlyIndex === -1)) ? '[' : '{';
    let endChar = startChar === '{' ? '}' : ']';
    let jsonData = jsonString.slice(jsonString.indexOf(startChar), jsonString.lastIndexOf(endChar) + 1);
    if (jsonData) {
        // Remove single line comments
        jsonData = jsonData.replace(/\/\/.*$/gm, '').trim();
        // Replace curly double quotes (“ ”) with straight double quotes (")
        jsonData = jsonData.replace(/[\u201C\u201D]/g, '"');
        // Replace curly single quotes (‘ ’) with straight single quotes (')
        jsonData = jsonData.replace(/[\u2018\u2019]/g, "'");
    }
    
    try {
        return JSON.parse(jsonData);
    } catch (error) {
        console.error('Failed to parse JSON:', error);
        console.error('JSON:', jsonData);
    }
}