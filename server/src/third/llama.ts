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