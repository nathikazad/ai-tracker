// // Import necessary modules
// import { readFileSync } from 'fs';

import { getEventTypes } from "./resources/eventTypes";

// // Read the file content
// const fileContent = readFileSync('specs/sleep.txt', 'utf8');

// // Function to parse the specs and log input and output
// function parseAndLogSpecs(text: string): void {
//   // Split the text into sections based on 'spec:'
//   const specs = text.split('spec:').slice(1); // Remove the first element as it will be empty

//   specs.forEach((spec, index) => {
//     // Trim and find the positions of 'input:' and 'output:' to isolate them
//     const trimmedSpec = spec.trim();
//     const inputIndex = trimmedSpec.indexOf('input:');
//     const outputIndex = trimmedSpec.indexOf('output:');

//     // Extract the title, input, and output sections
//     const title = trimmedSpec.substring(0, inputIndex).trim();
//     const input = trimmedSpec.substring(inputIndex + 6, outputIndex).trim();
//     const output = trimmedSpec.substring(outputIndex + 7).trim();

//     // Log the input and output
//     console.log(`Spec ${index + 1}: ${title}`);
//     console.log('Input:', input);
//     console.log('Output:', output);
//     console.log('---'); // Separator for readability
//   });
// }

// // Call the function with the file content
// parseAndLogSpecs(fileContent);
async function  main() {
    let res = await getEventTypes();
    console.log(res);
    
}
main()