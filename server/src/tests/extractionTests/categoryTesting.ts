import { log } from "console"
import { createEmbedding } from "../../third/openai"
import fs from 'fs'
import { Category, extractCategories, categoryDescriptions } from "../../resources/logic/eventLogic";
// import { Category } from "./extractionTests"



async function main () {
    // console.log("Starting");
    // await checkCategories();
    // await checkCategory("I did absolutely nothing today", [Category.Procrastinating])
}
main()

async function checkCategories() {
    await checkCategory("I did absolutely nothing for the last 50 minutes and scrolled around Instagram and YouTube", [Category.Distraction])
    await checkCategory("I did absolutely nothing today", [Category.Distraction])
    await checkCategory("I spent the last 30 minutes on instagram", [Category.Distraction])
    await checkCategory("I drank a cup of coffee", [Category.Eating])
    await checkCategory("I had a meeting with my boss", [Category.Meeting, Category.Working])
    await checkCategory("I went to a party last night", [Category.Meeting])
    await checkCategory("I made a sandwich", [Category.Cooking])
    await checkCategory("I made a butternut squash soup", [Category.Cooking])
    await checkCategory("I went to an investor meetup at the ferry building", [Category.Meeting]);
    await checkCategory("I swam for 30 minutes and I feel great.", [Category.Exercising, Category.Feeling]);
    await checkCategory("Going to sleep now.", [Category.Sleeping]);
    await checkCategory("I read the Gita for an hour", [Category.Reading]);
    await checkCategory("I am going to sleep now", [Category.Sleeping]);
    await checkCategory("I just woke up", [Category.Sleeping]);
    await checkCategory("I woke up at 6am", [Category.Sleeping]);
    await checkCategory("I'm feeling pretty exhausted and have had a headache for the last hour. I think its because I skipped dinner yesterday, I have to investigate to see if it is a repeating pattern", [Category.Feeling])
    await checkCategory("I’m leaving office. I couldn’t get anything done. I feel so irritated.", [Category.Feeling])
    await checkCategory("I did the normal routine and also I added some pull-ups. I did 15 minutes on the treadmill at very low speed and also tried a balancing exercise with the left glute activated. It seemed pretty good. I'm going to keep doing both of these.", [Category.Exercising])
    await checkCategory("Just got back from dancing, it wasn't so great, people were a bit too snobbish. I might have injured my knee, it hurts.", [Category.Dancing, Category.Feeling])
    await checkCategory("I just lost an hour trying to fix a stupid charts bug", [Category.Working, Category.Feeling])
    await checkCategory("I am going to swim for 20 minutes", [Category.Exercising])
    await checkCategory("I plan to swim at 1pm, for 40 minutes", [Category.Exercising])
    await checkCategory("I went to trader joe's and spent $100", [Category.Shopping])
    await checkCategory("I swam for 20 minutes, felt amazing", [Category.Exercising, Category.Feeling])
    await checkCategory("I will be with my dentist between 1pm to 2pm", [Category.Meeting])
    await checkCategory("I was be with my dentist between 10am to 11am", [Category.Meeting])
}

async function checkCategory(sentence: string, expected: Category[]) {
    // console.log(sentence);
    let actual = await extractCategories(sentence);
    // console.log(actual);
    // // check if actual contains expected
    let correct = true;
    for (let category of expected) {
        if (!actual.includes(category)) {
            correct = false;
        }
    }
    
    // check if arrays have exactly same elements by removing the elements from both arrays
    if([...new Set(actual)].sort().join() === [...new Set(expected)].sort().join()) {
        log("Matched");
    } else {
        console.log(sentence);
        console.log(`💣💣💣Mismatch: actual: ${toStr(actual)} != expected: ${toStr(expected)}`);
    }
    log("=====================================");
}

function toStr(categories: Category[]) {
    // stitch the categor names together
    let categoryStrings: string[] =  []
    for (let category of categories) {
        categoryStrings.push(category);
    }
    return categoryStrings;
}
