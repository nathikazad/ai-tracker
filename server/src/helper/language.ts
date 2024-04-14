import { complete3 } from "../third/openai";

export async function translateToSpanish(text: string) : Promise<string> {
    let prompt = `translate the text below to english:
    "${text}"`
    let resp = (await complete3(prompt, 0.2, 100, false));
    return resp
}