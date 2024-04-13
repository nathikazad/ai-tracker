import { complete3 } from "../third/openai";

export async function translateToSpanish(text: string) : Promise<string> {

    // let prompt = `if the text below in english or spanish:
    //     "${text.substring(0, 10)}"`
    // let resp = (await complete3(prompt, 0.2, 10));
    // if(resp.includes("spanish")){
        let prompt = `translate the text below to english:
        "${text}"`
        let resp = (await complete3(prompt, 0.2, 10, false));
        return resp
    // } 
    // return null
    
}