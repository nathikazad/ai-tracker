// import { parseEvent } from "./resources/logic"

import { classify } from "./resources/logic"

// import { generateTodosFromGoals } from "./resources/goal";

async function  main() {
    // generateTodosFromGoals(1);
    // parseEvent("I finished praying isha", 1)
    let resp = await classify("Cancel my spanish goal")
    console.log(resp);
    
}
main()