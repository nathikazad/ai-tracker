import { log } from "console";
import { extractJson, llamaComplete } from "../../third/llama";
import { complete4, createEmbedding } from "../../third/openai";
import fs from 'fs'
import { extractMetadata } from "./metadataLogic";

export enum Category {
    Sleeping = "Sleeping",
    WakingUp = "Wakingup",
    Meeting = "Meeting",
    Feeling = "Feeling",
    Reading = "Reading",
    Learning = "Learning",
    Eating = "Eating",
    Cooking = "Cooking",
    Praying = "Praying",
    Shopping = "Shopping",
    Chores = "Chores",
    Dancing = "Dancing",
    Working = "Working",
    Exercising = "Exercising",
    Distraction = "Distraction"
}

export const categoryDescriptions: { [key in Category]: string } =
{
    [Category.Sleeping]: "If a user explicitly says he is going to sleep or slept",
    [Category.WakingUp]: "If a user explicitly says, he woke or has woken up.",
    [Category.Meeting]: "If a user is with someone, meeting or speaking to someone, going to a party, get together or or an event",
    [Category.Feeling]: "If the user say how they feel or felt, emotionally or physically. Do not include if the user does not say how he felt.",
    [Category.Reading]: "If a user is reading or listening to a book.",
    [Category.Learning]: "If a user is learning or practicing something",
    [Category.Eating]: "If a user is eating or drinking something",
    [Category.Cooking]: "If a user is cooking or making something to eat",
    [Category.Praying]: "If a user is praying",
    [Category.Shopping]: "If a user is shopping or buying something",
    [Category.Chores]: "If a user is doing chores or cleaning or something similar",
    [Category.Dancing]: "If a user is talking about dancing",
    [Category.Working]: "If a user is working or doing something related to work",
    [Category.Exercising]: "If a user is exercising or working out, including gym and cardio",
    [Category.Distraction]: "If a user is getting distracted with youtube, netflix, social media, instagram or something very similar",
}

export enum Tense {
    Past = 'past',
    Present = 'present',
    Future = 'future',
}

export interface Interaction {
    statement: string;
    recordedAt: string;
}
export interface ASEvent {
    sentence?: string;
    tense: Tense
    categories: Category[];
    startTime?: string | null;
    endTime?: string | null;
    cost?: string | null;
    metadata?: any;
}

export async function extractEvents(interaction: Interaction): Promise<ASEvent> {
    // let events: ASEvent[] = [];
    let sentence = interaction.statement;
    let categories = await extractCategories(sentence);
    // console.log(`${sentence}: ${categories}`);
    let tense = await extractTense(sentence);
    let temporal = await extractTemporalInformation(sentence, interaction.recordedAt, categories, tense);
    let event: ASEvent = {
        sentence: sentence,
        categories: categories,
        tense: tense,
        startTime: convertTimeFormat(temporal.start_time),
        endTime: convertTimeFormat(temporal.end_time),
    }
    
    event = await extractMetadata(event);
    

    return event


    function convertTimeFormat(timeStr: string | null): string | null {
        if (!timeStr) {
            return null;
        }

        // check if time is in 12 hour format
        if (!timeStr.match(/^(\d{1,2}):(\d{2})\s?([ap]m)?$/)) {
            return null;
        }
        return timeStr.replace(/^(\d{1,2}):(\d{2})\s?([ap]m)?$/, (match, hour, minute, amPm) => {
            return `${hour.padStart(2, '0')}:${minute} ${amPm || ''}`;
        }).toLowerCase();
    }
}


export async function extractMultipleEvents(sentence: string): Promise<string[]> {

    let events = await breakdown(sentence)
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

export async function breakdown(sentence: string): Promise<string> {
    log(sentence)
    let prompt = `
    Given a sentence: "${sentence}"
    How many main actions is the user doing?
    Adverbs modifying the action should be considered as part of the action.
    Don't count verbs like have, going, is, am, got and need as main actions.
    If there is a gerund, count it as a verb but not the verb preceding it.
    
    Output specs:
    Give me output as json prefixed and suffixed by triple backticks,
    With fields
        count: number
        actions: string[]
    '\n`
    log(prompt)
    let output = await complete4(prompt, 0.1)
    return output
}

export async function createEmbeddings() {
    let categoryEmbeddings: { [key in Category]: Number[] } = {} as any;
    for (let [category, description] of Object.entries(categoryDescriptions)) {
        categoryEmbeddings[category as unknown as Category] = await createEmbedding(description);
    }
    // open and write to json file
    fs.writeFileSync("data/categoryEmbeddings.json", JSON.stringify(categoryEmbeddings));
}

export async function extractCategories(sentence: string): Promise<Category[]> {
    let closestCategories = await findClosestCategories(sentence);
    // console.log("Closest categories: ", closestCategories)
    let categories = await askGptForCategories(sentence, closestCategories);
    // console.log("Final categories: ", categories)
    // remove categories that are not in the enum
    categories = categories.filter((c: Category) => Object.values(Category).includes(c));
    return categories;

    async function findClosestCategories(phrase: string): Promise<Category[]> {
        let categoryEmbeddings = readEmbeddings();
        let embedding = await getEmbedding(phrase);
        let cosineSimilarityDictionary: { [key in Category]: Number } = {} as any;
        for (let [category, categoryEmbedding] of Object.entries(categoryEmbeddings)) {
            cosineSimilarityDictionary[category as Category] = getCosineSimilarity(embedding, categoryEmbedding);
        }
        // sort the dictionary by value
        let cosineSimilarityArray = Object.entries(cosineSimilarityDictionary).sort((a, b) => Number(b[1]) - Number(a[1]));
        let categories: Category[] = [];
        for (let [category, similarity] of cosineSimilarityArray) {
            if (Number(similarity) > 0.1) {
                categories.push(category as unknown as Category);
            }
        }
        // print distance of each category
        // for (let [category, similarity] of cosineSimilarityArray) {
        //     console.log(`${category}: ${similarity}`);
        // }
        // only include excersing or dancing, whichever is higher
        switch (categories[0]) {
            case Category.Dancing:
                categories = categories.filter(c => c != Category.Exercising);
                break;
        }
        // return only top 3
        return categories.slice(0, 4);
    }

    function readEmbeddings() {
        // get from database
        let categoryEmbeddings: { [key in Category]: Number[] } = JSON.parse(fs.readFileSync("data/categoryEmbeddings.json", 'utf-8'));
        return categoryEmbeddings;
    }

    async function askGptForCategories(sentence: string, filteredCategories: Category[]): Promise<Category[]> {
        // push procrastinating if it is not already in the list
        if (!filteredCategories.includes(Category.Distraction)) {
            filteredCategories.push(Category.Distraction);
        }
        if (!filteredCategories.includes(Category.Feeling)) {
            filteredCategories.push(Category.Feeling);
        }
        let prompt = `
        "${sentence}"\n
        Based on the sentence above, classify the event into one or more of the following categories:`
        for (let category of filteredCategories) {
            prompt += `\n\t- ${category}: (${categoryDescriptions[category]})`
        }
        prompt += `\n\t- None of the above`
        prompt += `\n\tGive me the name of the categories as an array of strings and nothing else`
        // console.log(prompt);
        let output = await llamaComplete(prompt, {
            toLowerCase: true,
            model: "70b",
            temperature: 0.1
        })
        // console.log(output);

        let categories = output.replace(/[\[\]]/g, '').split(',').map((s: string) => s.trim())
        // captitalize the first letter of each category
        categories = categories.map((c: string) => {
            c = c.replace(/['"]+/g, '');
            return c.trim().charAt(0).toUpperCase() + c.trim().slice(1);
        });
        return categories as Category[];
        // // remove all categories that are not in the enum
        // categories = categories.filter((c: Category) => Object.values(Category).includes(c));
        // if(categories.includes(Category.Dancing)){
        //     categories = categories.filter(c => c !== Category.Exercising);
        // }
        // if(categories.includes(Category.Sleeping)){
        //     categories = categories.filter(c => c !== Category.Feeling);
        // }
        // if(categories.includes(Category.Cooking)){
        //     categories = categories.filter(c => c !== Category.Eating);
        // }

    }

    function getDistance(embedding1: Number[], embedding2: Number[]): Number {
        let sum = 0;
        for (let i = 0; i < embedding1.length; i++) {
            sum += Math.pow(Number(embedding1[i]) - Number(embedding2[i]), 2);
        }
        return Math.sqrt(sum);
    }
    function getCosineSimilarity(embedding1: Number[], embedding2: Number[]): number {
        let dotProduct = 0;
        let normA = 0;
        let normB = 0;
        for (let i = 0; i < embedding1.length; i++) {
            dotProduct += Number(embedding1[i]) * Number(embedding2[i]);
            normA += Math.pow(Number(embedding1[i]), 2);
            normB += Math.pow(Number(embedding2[i]), 2);
        }
        if (normA === 0 || normB === 0) { // Prevent division by zero
            return 0;
        } else {
            return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
        }
    }

    async function getEmbedding(phrase: string) {
        // check if embedding already exists in file

        let embeddings: { [key: string]: Number[] } = JSON.parse(fs.readFileSync("data/savedEmbeddings.json", 'utf-8'));
        if (embeddings[phrase]) {
            return embeddings[phrase];
        } else {
            console.log("Creating new embedding");
            let embedding = await createEmbedding(phrase);
            embeddings[phrase] = embedding;
            fs.writeFileSync("data/savedEmbeddings.json", JSON.stringify(embeddings));
            return embedding;
        }
    }
}

export async function extractTense(sentence: string) {//}: Promise<Status> {
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

    // check if output is one of the three
    if (output === Tense.Past || output === Tense.Present || output === Tense.Future) {
        return output as Tense;
    } else {
        return Tense.Past;
    }

    // return output as Tense;
}

export async function extractTemporalInformation(sentence: string, recordedTime: string, category: Category[], tense: Tense): Promise<any> {
    function getVerb(temp: Tense) {
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
        if (tense === Tense.Past)
            if (category.includes(Category.Sleeping)) {
                return "The time user slept is considered start_time and the time he woke up is considered end_time. If start_time is not mentioned, say null. If end_time is not mentioned, assume end_time is recorded time"
            } else {
                return `
                If start_time is not specified, make it null
                If end_time is not specified, make it the time of the statement`
            }
        else
            return "If start time is not given, assume it is the time of the statement. If end time is not given, say null";

    }

    let verb = getVerb(tense);
    let addition = getAddition(tense, category);
    let prompt = `Given that user said: "${sentence}" at ${recordedTime}\n
        Given that the user ${verb} ${category}, if mentioned, give me the start time and/or end time of the user
        ${addition}
        Give me output as a json object, prefixed and suffixed by triple backticks, 
        with the fields 
            start_time?: string //in format 'hh:mm am/pm'
            end_time?: string //in format 'hh:mm am/pm'
            is_duration_given?: boolean //true if user explicitly mentioned how long they did the activity for`

    // console.log(prompt);
    let output = await llamaComplete(prompt, {
        model: "70b",
        temperature: 0.1,
        toLowerCase: true
    })
    // console.log(output);

    let json = extractJson(output);
    if(!json.start_time && json.is_duration_given){
        console.log(json)
        console.log("Finding duration");
        let prompt = `Given that user said: "${sentence}" at ${recordedTime}\n
        Calculate the start_time by subtracting the duration from the end_time.
        Give me output as a json object, prefixed and suffixed by triple backticks, 
        with the field
            start_time: string //in format 'hh:mm am/pm'`

        console.log(prompt);
        let output = await llamaComplete(prompt, {
            model: "70b",
            temperature: 0.1,
            toLowerCase: true
        })
        console.log(output);
        let secondJson = extractJson(output);
        return {
            ...json,
            ...secondJson
        }
    } else {
        return json;
    }
}



