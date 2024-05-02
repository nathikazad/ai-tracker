import Replicate from "replicate";
import { config } from "../config";
const replicate = new Replicate({
    auth: config.replicateApiKey
});

import Groq from "groq-sdk";

const groq = new Groq(
    {
        apiKey:config.groqApiKey

    }
)

export async function llamaComplete(prompt: string, temperature: number | undefined = undefined, max_tokens: number = 100, toLowerCase : boolean = true) {
    let startTime = Date.now();
    let r = await groq.chat.completions.create({
        messages: [
            {
                role: "user",
                content: prompt
            }
        ],
        model: "llama3-8b-8192",
      
      max_tokens: max_tokens,
      temperature: temperature
    });
    let endTime = Date.now();
    console.log(`Time taken: ${endTime - startTime}ms`);
    // console.log(r.usage)
    let message =  r.choices[0].message.content
    return toLowerCase ? message.replace(/\n/g, "").replace(/"/g, '').trim().toLocaleLowerCase() : message
}

export function oldExtractJsonAndNote(input: string): { json: any | null, note: string | undefined } {
    // Regular expression to extract JSON between triple backticks
    const jsonRegex = /```([\s\S]*?)```/;
    const jsonMatch = input.match(jsonRegex);

    // Extract the JSON data
    let jsonData = jsonMatch ? jsonMatch[1].trim() : null;

    // Remove comments from JSON (simple way to handle end-of-line comments)
    if (jsonData) {
        jsonData = jsonData.replace(/\/\/.*$/gm, '').trim();
        // Replace curly double quotes (“ ”) with straight double quotes (")
        jsonData = jsonData.replace(/[\u201C\u201D]/g, '"');
        // Replace curly single quotes (‘ ’) with straight single quotes (')
        jsonData = jsonData.replace(/[\u2018\u2019]/g, "'");
    }

    // Parse JSON if valid JSON data is extracted
    let parsedJson = null;
    if (jsonData) {
        try {
            parsedJson = JSON.parse(jsonData);
        } catch (error) {
            console.error('Failed to parse JSON:', error);
            console.error('JSON:', jsonData);
            parsedJson = null;
        }
    }

    // Remove the JSON block from the input to isolate the note
    let remainingText = input.replace(jsonRegex, "").trim();

    // Extract the note, if any, that comes after the JSON block
    let noteData = remainingText.length > 0 ? remainingText : null;

    return {
        json: parsedJson,
        note: noteData?.split('\n').map(line => line.trim()).join(' ')
    };
}

export function extractJsonAndNote(jsonString: string): any {
    let jsonData = jsonString.slice(jsonString.indexOf('{'), jsonString.lastIndexOf('}') + 1);
    // console.log(jsonSubString);
    if (jsonData) {
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

    // const input = {
    //     top_k: 50,
    //     top_p: 0.9,
    //     prompt: prompt,
    //     max_tokens: 512,
    //     min_tokens: 0,
    //     temperature: 0.6,
    //     prompt_template: "<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\nYou are an assistant helping to interpret human language into logs.<|eot_id|><|start_header_id|>user<|end_header_id|>\n\n{prompt}<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n",
    //     presence_penalty: 1.15,
    //     frequency_penalty: 0.2
    // };
        // const output = await replicate.run("meta/meta-llama-3-70b-instruct", { input });
    // console.log(`prompt: ${prompt}`)
    // return (output as Array<string>).join("")