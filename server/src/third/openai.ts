import OpenAI from 'openai';
import { config } from "./../config";
import fs from 'fs';

const openai = new OpenAI({
  apiKey: config.openApiKey, // This is the default and can be omitted
});

export async function createEmbedding(input: string): Promise<Number[]> {
  const result = await openai.embeddings.create({
    input,
    model: "text-embedding-3-small",
  });
  return result.data[0].embedding
}

export async function complete4(prompt: string, temperature: number | null = null, max_tokens: number = 100, toLowerCase : boolean = true) {
  const result = await openai.chat.completions.create({
    messages: [
      {
        role: "user",
        content: prompt
      }
    ],
    model: "gpt-4-0125-preview",
    max_tokens: max_tokens,
    temperature: temperature,
    // response_format: {
    //   type: "json_object"
    // }
  });
  let message = result.choices[0].message.content!
  return toLowerCase ? message.trim().toLocaleLowerCase() : message
}

export async function complete3(prompt: string, temperature: number | null = null, max_tokens: number = 100, toLowerCase : boolean = true) {
  const result = await openai.completions.create({
    prompt,
    model: "gpt-3.5-turbo-instruct",
    max_tokens: max_tokens,
    temperature:temperature
  });
  // console.log(result.usage, result.choices[0].finish_reason);

  let message = result.choices[0].text
  return toLowerCase ? message.replace(/\n/g, "").replace(/"/g, '').trim().toLocaleLowerCase() : message
}

export async function speechToText(filePath: string, language?: string) {
  return openai.audio.transcriptions.create({
    file: fs.createReadStream(filePath),
    language: language ?? "en",
    model: "whisper-1"
  })
}

