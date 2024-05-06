import { log } from "console";
import { extractJson, llamaComplete } from "../../third/llama";
import { createEmbedding } from "../../third/openai";
import fs from 'fs'

export enum Category {
    Sleeping = "Sleeping",
    Meeting = "Meeting",
    Feeling = "Feeling",
    Reading = "Reading",
    Eating = "Eating",
    Cooking = "Cooking",
    Praying = "Praying",
    Shopping = "Shopping",
    Dancing = "Dancing",
    Working = "Working",
    Exercising = "Exercising",
    Distraction = "Distraction",
    Laundry = "Laundry",
}

export const categoryDescriptions: { [key in Category]: string } =
{
    [Category.Sleeping]: "If a user is going to sleep or waking up",
    [Category.Meeting]: "If a user is with someone, meeting or speaking to someone, going to a party, get together or or an event",
    [Category.Feeling]: "If a user is feeling a certain way, emotionally or physically",
    [Category.Reading]: "If a user is reading or listening to a book.",
    [Category.Eating]: "If a user is eating or drinking something",
    [Category.Cooking]: "If a user is cooking or making something to eat",
    [Category.Laundry]: "If a user is doing laundry like washing clothes",
    [Category.Praying]: "If a user is praying",
    [Category.Shopping]: "If a user is shopping or buying something",
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
    tense: Tense
    categories: Category[];
    startTime?: string | null;
    endTime?: string | null;
    cost?: string | null;
}

export async function extractEvents(interaction: Interaction): Promise<ASEvent[]> {
    let events: ASEvent[] = [];
    // let sentence = interaction.statement;
    let sentences = await extractMultipleEvents(interaction.statement);
    log(sentences);
    for (let sentence of sentences) {
        console.log(sentence);
        let categories = await extractCategories(sentence);
        // console.log(`${sentence}: ${categories}`);
        let tense = await extractTense(sentence);
        let temporal = await extractTemporalInformation(sentence, interaction.recordedAt, categories, tense);
        let event: ASEvent = {
            categories: categories,
            tense: tense,
            startTime: convertTimeFormat(temporal.start_time),
            endTime: convertTimeFormat(temporal.end_time),
        }
        events.push(event);
    }
    return events;

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

    async function breakdown(sentence: string): Promise<string> {
        let prompt = `
        Given a sentence: "${sentence}"
        How many sentences are there in this statement
        Give me output as a single number
        '\n`
        let output = await llamaComplete(prompt, {
            model: "70b",
            temperature: 0.1
        })

        let totalSentences = parseInt(output);
        if (totalSentences > 5) {
            return `1. ${sentence}`
            // need a better check to see if user is recounting a story or dream or something
        }
        else if (totalSentences > 1) {
            let prompt2 = `
            Given a sentence: "${sentence}"
            Break down the statement into ${totalSentences} events, print them as numbered list of events separated by newlines.
            Say each one in first person
            Include time information only if given`
            let output = await llamaComplete(prompt2, {
                model: "70b",
                temperature: 0.1
            })
            return output;
        } else {
            return `1. ${sentence}`

        }
    }
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
            case Category.Exercising:
                categories = categories.filter(c => c != Category.Dancing);
                break;
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
        Based on the sentence above and what the user is doing at the moment, classify the event into one or more of the following categories:`
        for (let category of filteredCategories) {
            prompt += `\n\t- ${category}: (${categoryDescriptions[category]})`
        }
        prompt += `\n\tGive me the name of the categories as an array of strings and nothing else`
        // console.log(prompt);
        let output = await llamaComplete(prompt, {
            toLowerCase: true,
            model: "8b",
            temperature: 0.1
        })
        console.log(output);

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
                return `If start is not specified but the user says how long he did the event for, calculate the start time. Otherwise say it is null
            If end time is not specified, make it null`
            }
        else
            return "If start time is not given, assume it is the time of the statement. If end time is not given, say null";

    }

    let verb = getVerb(tense);
    let addition = getAddition(tense, category);
    let prompt = `Given that user said: "${sentence}" at ${recordedTime}\n
        Given that the user ${verb} ${category}, if mentioned, give me the start time and/or end time of the user
        ${addition}
        Give me output as only a json object, prefixed and suffixed by triple backticks, with only the fields start_time and/or end_time in format 'hh:mm am/pm'`

    let output = await llamaComplete(prompt, {
        model: "70b",
        temperature: 0.1,
        toLowerCase: true
    })
    // console.log(output);

    return extractJson(output);
}



