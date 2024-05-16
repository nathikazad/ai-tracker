import { log } from "console";
import { extractJson, llamaComplete } from "../../third/llama";
import { complete4, createEmbedding } from "../../third/openai";
import { extractMetadata } from "./metadataLogic";
import { convertToUtc, extractTime, toPST } from "../../helper/time";
import { createEvent, getCategories, getClosestSleepEvent, getLastEvent, updateEvent } from "../events/eventLogicDb";
import { getHasura } from "../../config";
import { get } from "http";
import { $ } from "../../generated/graphql-zeus";

export enum Category {
    Sleeping = "sleeping",
    WakingUp = "wakingup",
    Meeting = "meeting",
    Feeling = "feeling",
    Reading = "reading",
    Learning = "learning",
    Eating = "eating",
    Cooking = "cooking",
    Praying = "praying",
    Shopping = "shopping",
    Chores = "chores",
    Dancing = "dancing",
    Working = "working",
    Exercising = "exercising",
    Distraction = "distraction",
    Unknown = "unknown"
}


export enum Tense {
    Past = 'past',
    Present = 'present',
    Future = 'future',
}

export interface Interaction {
    id: number;
    userId: number;
    statement: string;
    recordedAt: string;
    timezone: string;
}
export interface ASEvent {
    sentence?: string;
    tense: Tense
    categories: Category[];
    startTime: string | null;
    endTime: string | null;
    cost?: string | null;
    metadata?: any;
}

export async function interactionToEvent(interaction: Interaction): Promise<void> {
    let event = await extractEventInfo(interaction)
    console.log(`Event: \n ${JSON.stringify(event, null, 4)}`)
    console.log(`\t start_time: ${toPST(event.startTime)} \n\t end_time: ${toPST(event.endTime)}`);
    if (event.categories.length == 0) {
        createEvent(event, Category.Unknown, interaction.userId, interaction.id)
    }
    else {
        for (let category of event.categories) {
            if (category == Category.Sleeping) {
                let closestSleepingEvent = await getClosestSleepEvent(interaction.userId, event.startTime, event.endTime)
                if (closestSleepingEvent != null) {
                    console.log(`Closest Sleeping Event: \n ${closestSleepingEvent.id} ${toPST(closestSleepingEvent.start_time)}  ${toPST(closestSleepingEvent.end_time)}`)
                    event.metadata.locks = closestSleepingEvent?.metadata?.locks || {}
                    if (event.startTime != null) {
                        event.metadata.locks.start_time = true
                    }
                    if (event.endTime != null) {
                        event.metadata.locks.end_time = true
                    }
                    await updateEvent(closestSleepingEvent.id, event.startTime ?? closestSleepingEvent.start_time, event.endTime ?? closestSleepingEvent.end_time, event.metadata, interaction.id)
                    continue
                } else {
                    console.log(`Creating new sleep event`)
                    await createEvent(event, category, interaction.userId, interaction.id)
                }
            }
            // For possibly long events like learning, shopping, cooking, if the end time is mentioned without start time, update the end time of the last event
            else if ([Category.Learning, Category.Shopping, Category.Cooking].includes(category)
                && event.startTime == null && event.endTime != null) {
                let lastEvent = await getLastEvent(interaction.userId, category, event.endTime)
                if (lastEvent != null && lastEvent.end_time == null) {
                    console.log(`Last Event: \n ${JSON.stringify(lastEvent, null, 4)}`)
                    console.log(`Updating end time of last event`)
                    await updateEvent(lastEvent.id, lastEvent.start_time, event.endTime, {
                        ...lastEvent.metadata,
                        ...event.metadata
                    }, interaction.id)
                } else {
                    console.log(`Creating new event 1`)
                    await createEvent(event, category, interaction.userId, interaction.id)
                }
            } else {
                console.log(`Creating new event 2`)
                await createEvent(event, category, interaction.userId, interaction.id)
            }
        }
    }
}

export async function extractEventInfo(interaction: Interaction): Promise<ASEvent> {
    // let events: ASEvent[] = [];
    let timeInTimezone = extractTime(interaction.recordedAt, interaction.timezone);
    let sentence = interaction.statement;
    let categories = await extractCategories(sentence);
    // console.log(`${sentence}: ${categories}`);
    let tense = await extractTense(sentence);
    let temporal = await extractTemporalInformation(sentence, timeInTimezone!, categories, tense);
    console.log(`temporal: ${JSON.stringify(temporal, null, 4)}`);
    let event: ASEvent = {
        sentence: sentence,
        categories: categories,
        tense: tense,
        startTime: convertTimeFormat(temporal.start_time),
        endTime: convertTimeFormat(temporal.end_time),
    }
    
    event.startTime = convertToUtc(event.startTime, interaction.recordedAt, interaction.timezone)!;
    event.endTime = convertToUtc(event.endTime, interaction.recordedAt, interaction.timezone)!;
    event = await extractMetadata(event);
    return event


    function convertTimeFormat(time: string | null): string | null {
        if (!time) {
            return null;
        }
        let parts = time.split(' ');
        let date = time.split(' ')[0];
        let timeStr = time.split(' ')[1];
        if (parts.length > 2) {
            timeStr += " " + parts[2];
        }

        // check if time is in 12 hour format
        if (!timeStr.match(/^(\d{1,2}):(\d{2})\s?([ap]m)?$/)) {
            return null;
        }
        return date + " " + timeStr.replace(/^(\d{1,2}):(\d{2})\s?([ap]m)?$/, (match, hour, minute, amPm) => {
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


export async function extractCategories(sentence: string): Promise<Category[]> {
    let dbCategories = await getCategories();
    let closestCategories = await findClosestCategories(sentence);
    // console.log("Closest categories: ", closestCategories)
    let categories = await askGptForCategories(sentence, closestCategories);
    // console.log("Final categories: ", categories)
    // remove categories that are not in the enum
    categories = categories.filter((c: Category) => Object.values(Category).includes(c));
    return categories;

    async function findClosestCategories(phrase: string): Promise<Category[]> {
        let embedding = await createEmbedding(phrase);
        let cosineSimilarityDictionary: { [key in Category]: Number } = {} as any;
        for (let [category, categoryEmbedding] of Object.entries(dbCategories.categoryEmbeddings)) {
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
            prompt += `\n\t- ${category}: (${dbCategories.categoryDescriptions[category]})`
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
            return c.trim();
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
            start_time?: string //in format 'mm/dd hh:mm am/pm'
            end_time?: string //in format 'mm/dd hh:mm am/pm'
            is_duration_given?: boolean //true if user explicitly mentioned how long they did the activity for`

    // console.log(prompt);
    let output = await complete4(prompt, 0.1, 100, true);
    // console.log(output);

    let json = extractJson(output);
    // if(json.end_time == null) {
    //     json.end_time = recordedTime;
    // }
    if (!json.start_time && json.is_duration_given) {
        console.log(json)
        console.log("Finding duration");
        let prompt = `Given that user said: "${sentence}" at ${recordedTime}\n
        Calculate the start_time by subtracting the duration from the end_time.
        Give me output as a json object, prefixed and suffixed by triple backticks, 
        with the field
            start_time: string //in format 'mm/dd hh:mm am/pm'`

        // console.log(prompt);
        let output = await complete4(prompt, 0.1, 100, true);
        // console.log(output);
        let secondJson = extractJson(output);
        return {
            ...json,
            ...secondJson
        }
    } else {
        return json;
    }
}



