// import { parseEvent } from "./resources/logic"


import { parse } from "./resources/logic"

// import { classify } from "./resources/logic"

// import { generateTodosFromGoals } from "./resources/goal";

async function main() {
    // generateTodosFromGoals(1);
    // parseEvent("I finished praying isha", 1)
    // let resp = await classify("Cancel my spanish goal")
    // console.log(resp);
    parse("Call my mother once a week during work commute", 1, 75)
    
}
main()

