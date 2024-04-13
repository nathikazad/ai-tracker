import { complete3 } from "../third/openai";

export async function isSpanish(text: string) : Promise<string | null> {

    let prompt = `if the text below in english or spanish:
        "${text.substring(0, 10)}"`
    let resp = (await complete3(prompt, 0.2, 10));
    if(resp.includes("spanish")){
        prompt = `translate the text below to english:
        "${text}"`
        let resp = (await complete3(prompt, 0.2, 10));
        return resp
    } 
    return null
    
}