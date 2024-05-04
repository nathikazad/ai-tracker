import e from "express";
import { extractJson, llamaComplete } from "../third/llama";
import { log } from "console";
import { Category } from "./doDistanceTesting";


export enum Tense {
    Past = 'past',
    Present = 'present',
    Future = 'future',
}

interface Interaction {
    statement: string;
    recordedAt: string;
}

export interface Event {
    tense: Tense
    categories: Category[];
    startTime?: string | null;
    endTime?: string | null;
    cost?: string | null;
}

async function main() {
    // await checkBreakdowns()
    // await checkTenses()
    // await checkTemporals()
    // second check for feeling
    // check for cost
    // checkTense

}
// main()

async function checkTemporals() {
    await checkTemporals("I will sleep for 8 hours", "6:30am", Category.Sleeping, Tense.Future, "6:30 am", "2:30 pm")
    await checkTemporals("I woke up at 6", "7:30am", Category.Sleeping, Tense.Past, null, "6:00 am")
    await checkTemporals("I had coffee at 11", "12:30pm", Category.Eating, Tense.Past, "11:00 am", "11:00 am")
    await checkTemporals("I had coffee", "12:30pm", Category.Eating, Tense.Past, "12:30 pm", "12:30 pm")
    
    await checkTemporals("I am going to swim for 20 minutes", "2:22pm", Category.Exercising, Tense.Future, "2:22 pm", "2:42 pm")
    await checkTemporals("I plan to swim at 1pm, for 40 minutes", "11:30am", Category.Exercising, Tense.Future, "1:00 pm", "1:40 pm")
    await checkTemporals("I went to trader joe's and spent $100", "7:00pm", Category.Shopping, Tense.Past, "7:00 pm", "7:00 pm")
    await checkTemporals("I went to trader joe's at 6 and spent $100", "7:00pm", Category.Shopping, Tense.Past, "6:00 pm", "6:00 pm")
    await checkTemporals("I swam for 20 minutes, felt amazing", "12:40pm", Category.Exercising, Tense.Past, "12:20 pm", "12:40 pm")
    await checkTemporals("I will be with my dentist between 1pm to 2pm", "10am", Category.Meeting, Tense.Future, "1:00 pm", "2:00 pm")
    await checkTemporals("I was be with my dentist between 10am to 11am", "12:20pm", Category.Meeting, Tense.Past, "10:00 am", "11:00 am")
    async function checkTemporals(sentence: string, recordedTime: string, category: Category, tense: Tense, expectedStartTime: string | null, expectedEndTime: string | null) {
        let output = await getTemporalInformation(sentence, recordedTime, [category], tense);
        if (output.start_time?.replace(/^0+(\d+)/, '$1') == expectedStartTime && output.end_time?.replace(/^0+(\d+)/, '$1') == expectedEndTime) {
            console.log("Matched");
        } else {
            console.log(`Mismatch: ${sentence}`); 
            if(output.start_time != expectedStartTime)
                console.log(`\tstart time actual: ${output.start_time} != expected: ${expectedStartTime}`);
            if(output.end_time != expectedEndTime)
                console.log(`\tend time actual: ${output.end_time} != expected: ${expectedEndTime}`);
        }
    }
}


export async function getTemporalInformation(sentence: string, recordedTime: string, category: Category[], tense: Tense) : Promise<any> {
    function getVerb(temp: Tense){ 
        switch (temp) {
            case Tense.Past:
                return "was";
            case Tense.Present:
                return "is";
            case Tense.Future:
                return "will be";
        }
    }
    
    function getAddition(temp: Tense, category: Category[]) { 
    if(tense === Tense.Past) 
        if (category.includes(Category.Sleeping))
            return "If end time is not given, assume it is the time of the statement. If start time is not given, say null"
        else 
            return "If start time is not specified, mark it null. If end time is not specified, assume end_time equal to recorded time." 
    else 
        return "If start time is not given, assume it is the time of the statement. If end time is not given, say null";
        
    }

    let verb = getVerb(tense);
    let addition = getAddition(tense, category);
    let prompt =  `Given that user said: "${sentence}" at ${recordedTime}\n
        Given that the user ${verb} ${category}, if mentioned, give me the start time and/or end time of the user
        ${addition}
        Give me output as only a json object, prefixed and suffixed by triple backticks, with only the fields start_time and/or end_time in format 'hh:mm am/pm'`
    console.log(prompt);
    
        let output = await llamaComplete(prompt, {
        model: "70b",
        temperature: 0.1
    })
    console.log(output);
    
    return extractJson(output);
}

export async function extractTense(sentence: string){//}: Promise<Status> {
    let prompt = `Given the sentence "${sentence}", determine the tense of the verb in the sentence.
        If the user says he did something in the past, consider it as past tense.
        If the user says he is doing something or going to do something in very near future or uses the word now, consider it as present tense.    
        If the user says he is going to/want to/have to/will do/need to something in the future, consider it as future tense.
        Just output a single word: past, present or future.
        `
    let output = await llamaComplete(prompt, {
        toLowerCase: true,
        model: "70b",
    });
    
    return output as Tense;
}
async function breakdown(sentence:string): Promise<string> {
    console.log(sentence);
    
    let prompt = `
    Given a sentence: "${sentence}"
    If there is more than one event, break down the following text into a numbered new line separated list of events, 
    Each event has to be very different from the other, like the event's action must be different from the previous event.
    Say each event in first person, using I.
    Include the time information only if given
    '\n`
    let output = await llamaComplete(prompt, {
        model: "70b",
        temperature: 0.1
    })
    return output;
}

export async function extractEvents(sentence: string): Promise<string[]> {
    console.log(sentence);
    
    let events = await breakdown(sentence)
    console.log(events);
    
    // Split the text into lines
    const lines = events.split('\n');
    // Define a regex to match lines starting with one or more digits followed by a dot
    const regex = /^\d+\.\s*(.*)/;
    const results: string[] = [];

    for (const line of lines) {
        const match = line.match(regex);
        if (match) {
            // If a line matches, add the first capturing group (after the number and dot) to results
            results.push(match[1].trim());
        }
    }

    return results;
}


async function checkTenses() {
    await checkTense("Woke up at 6am", Tense.Past)
    await checkTense("I prayed at 6.20", Tense.Past)
    await checkTense("I worked for an hour till like about 7.20", Tense.Past)
    await checkTense("Going to sleep now", Tense.Present)
    await checkTense("Will pray now", Tense.Present)
    await checkTense("Going to pray first", Tense.Future)
    await checkTense("Will have to wake up early tomorrow", Tense.Future)
    await checkTense("Want to wake up early tomorrow", Tense.Future)
    await checkTense("I have to see Sid in the evening", Tense.Future)
    await checkTense("I need to see Sid in the evening", Tense.Future)
    async function checkTense(sentence: string, expected: Tense) {
        let actual = await extractTense(sentence);
        if (actual === expected) {
            console.log("Matched");
        } else {
            console.log(`Mismatch: ${sentence} actual: ${actual} != expected: ${expected}`);
        }
    }
}

async function checkBreakdowns() {
    await checkBreakdown("Woke up at 6am, I prayed at 6.20 and then afterwards I worked for an hour till like about 7.20 and then I spent the last 15 minutes on YouTube. And now I am going to get ready for work.", [Category.Sleeping, Category.Praying, Category.Working, Category.Procrastinating])
    await checkBreakdown("I practiced dancing from 10 to 10 40 p.m. and I was on YouTube for about 20-30 minutes. I finished praying Isha and now I'm going to sleep.", [Category.Dancing, Category.Procrastinating, Category.Praying, Category.Sleeping])
    await checkBreakdown("I spent $30 at TJ's", [Category.Shopping])
    // await checkBreakdown("I did absolutely nothing today", [Category.Procrastinating])
    // await checkBreakdown("I spent the last 30 minutes on instagram", [Category.Procrastinating])
    // await checkBreakdown("I drank a cup of coffee", [Category.Eating])
    // await checkBreakdown("I ran a mile", [Category.Exercising])
    // await checkBreakdown("I did absolutely nothing for the last 50 minutes and scrolled around Instagram and YouTube", [Category.Procrastinating])
    async function checkBreakdown(sentence: string, expected: Category[]) 
    {
        
        let events = extractEvents(sentence);
        log(events);
        // get categories of all the events
        // let categories = []
        // for (let event of events) {
        //     let category = await getCategories(event);
        //     categories.push(...category);
        // }
        // // check if the categories match the expected categories even if not in order
        // let matched = true; 
        // for (let category of expected) {
        //     if (!categories.includes(category)) {
        //         matched = false;
        //         break;
        //     }
        // }
        // if (matched) {
        //     console.log("Matched");
        // } else {
        //     console.log(sentence);
        //     console.log("Mismatch");
        //     console.log(categories, expected)
        // }
    }
}
