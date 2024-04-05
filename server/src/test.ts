// import { parseEvent } from "./resources/logic"

import { verifyAppleJwt } from "./resources/apple"

// import { classify } from "./resources/logic"

// import { generateTodosFromGoals } from "./resources/goal";

async function main() {
    // generateTodosFromGoals(1);
    // parseEvent("I finished praying isha", 1)
    // let resp = await classify("Cancel my spanish goal")
    // console.log(resp);
    let decoded = await verifyAppleJwt("eyJraWQiOiJsVkhkT3g4bHRSIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmV2b2wuSGlzdG9yeSIsImV4cCI6MTcxMjQxOTkwOSwiaWF0IjoxNzEyMzMzNTA5LCJzdWIiOiIwMDEwMTcuOGNjZmM5ZTc0ZjllNDVmM2JkNWNmOWYzYzZkZDc1MTkuMDA0MyIsImNfaGFzaCI6IndmMHVIdWxreVB4X3duVkZVWHJzZWciLCJhdXRoX3RpbWUiOjE3MTIzMzM1MDksIm5vbmNlX3N1cHBvcnRlZCI6dHJ1ZX0.OntgUJPsbJ25Fl3InTiC7PMn3tLrhRDymJ-H1W5PJPdV1u5-rya-2urITvi5sMBrYUwkrHR0yRrx8m4XL8NpMvaqQrauyrfp_Mu9v-BWccZOGjqQLnIhZsBb5vQuf0bZIH_9QJd5JjDCD3gSK5plt5fXgXYR2hn5CX9RUZpiDFniXrWD_UPZNWyxwCDd8wNjNkz0V82paDku4iDImSCpJTQxTQEBIjhQIeUGoOoTuN6aabbybjJCENzIoVGaF0_XgEOCOQruGSVrKSGuNw1OSItEFROW8wlTXJ7I0J62th5kZUr0_13dTx5_TtOFIAOvKItksV0G1KgqnzavW-uH-g")
    console.log(decoded);
    
}
main()

