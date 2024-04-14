// import { isSpanish } from "./helper/language"

import { parseEvent } from "./resources/logic"



// import { parseUserRequest } from "./resources/logic"

// import { classify } from "./resources/logic"

// import { generateTodosFromGoals } from "./resources/goal";

async function main() {

//     // isSpanish("Ya terminé de hacer el mercado.")
//     await convert("Nueve AM, desperté.")
//     await convert("Una cuarenta y cuatro. Apenas voy a dormir.")
//     await convert("Hola, hoy usé la copa menstrual con éxito.")
//     await convert("Hi my name is Nathik")
//     await convert("I finished cooking")
    parseEvent("went to gym", 7, 244)
    
}

// async function convert(text: string) {
//     let resp = (await isSpanish(text)) || text
//     console.log(resp);
    
// }
main()

