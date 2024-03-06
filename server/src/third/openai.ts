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

