import OpenAI from 'openai';
import { config } from "./../config";
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

export async function complete(prompt: string) {
  const result = await openai.chat.completions.create({
      messages: [
        {
          role: "user",
          content: prompt
        }
      ],
      model: "gpt-4-0125-preview",
      max_tokens: 1000,
      response_format: {
        type: "json_object"
      }
    });
  return result.choices[0].message.content!;
}

export async function complete3(prompt: string) {
  const result = await openai.completions.create({
      prompt,
      model: "gpt-3.5-turbo-instruct",
      max_tokens: 1000,
    });
  console.log(result.usage, result.choices[0].finish_reason);
  
  return result.choices[0].text;
}


