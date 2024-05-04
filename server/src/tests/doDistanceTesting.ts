import { log } from "console"
import { createEmbedding } from "../third/openai"
import fs from 'fs'
import { llamaComplete } from "../third/llama";
import { Event, extractEvents, extractTense, getTemporalInformation } from "./extractionTests";
// import { Category } from "./extractionTests"
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
    Procrastinating = "Procrastinating"
}
let categoryDescriptions: { [key in Category]: string } =
{
    [Category.Sleeping]: "If a user is sleeping, going to sleep or waking up",
    [Category.Meeting]: "If a user is with someone, meeting or speaking to someone, going to a party, get together or or an event",
    [Category.Feeling]: "If a user is feeling a certain way, emotionally or physically",
    [Category.Reading]: "If a user is reading or listening to a book.",
    [Category.Eating]: "If a user is eating or drinking something",
    [Category.Cooking]: "If a user is cooking or making something to eat",
    [Category.Praying]: "If a user is praying",
    [Category.Shopping]: "If a user is shopping or buying something",
    [Category.Dancing]: "If a user is dancing",
    [Category.Working]: "If a user is working or doing something related to work",
    [Category.Exercising]: "If a user is exercising or working out, including gym and cardio",
    [Category.Procrastinating]: "If a user is procrastinating or loafing around doing something they are not supposed to do",
}

async function main () {
    console.log("Starting");
    
    // await createEmbeddings();
    
    // let categories = await getCategories("I just woke up")
    // await checkCategories();


    // await checkBreakdown("I practiced dancing from 10 to 10 40 p.m. and I was on YouTube for about 20-30 minutes. I finished praying Isha and now I'm going to sleep.", [Category.Dancing, Category.Procrastinating, Category.Praying, Category.Sleeping])
    let sentences = await extractEvents("I prayed at 10:00am")
    log(sentences);
    for (let sentence of sentences) {
        let categories = await getCategories(sentence);
        console.log(`${sentence}: ${categories}`);
        let tense = await extractTense(sentence);
        let temporal = await getTemporalInformation(sentence, "12:30pm", categories, tense);
        let event: Event = {
            categories: categories,
            tense: tense,
            startTime: temporal.start_time,
            endTime: temporal.end_time,
        }
        console.log(event);
    }
    
}
main()

async function checkCategories() {
    await checkCategory("I did absolutely nothing for the last 50 minutes and scrolled around Instagram and YouTube", [Category.Procrastinating])
    await checkCategory("I did absolutely nothing today", [Category.Procrastinating])
    await checkCategory("I spent the last 30 minutes on instagram", [Category.Procrastinating])
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

async function createEmbeddings() {
    let categoryEmbeddings: { [key in Category]: Number[] } = {} as any;
    for (let [category, description] of Object.entries(categoryDescriptions)) {
        categoryEmbeddings[category as unknown as Category] = await createEmbedding(description);
    }
    // open and write to json file
    fs.writeFileSync("data/categoryEmbeddings.json", JSON.stringify(categoryEmbeddings));
}

function readEmbeddings() {
    let categoryEmbeddings: { [key in Category]: Number[] } = JSON.parse(fs.readFileSync("data/categoryEmbeddings.json", 'utf-8'));
    return categoryEmbeddings;
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

async function getCategories(sentence: string): Promise<Category[]> {
    let closestCategories = await findClosestCategories(sentence);
    // console.log(`Closest categories: ${closestCategories}`);
    let categories = await askLlama(sentence, closestCategories);
    // console.log(`Categories: ${categories}`);
    // remove categories that are not in the enum
    categories = categories.filter((c: Category) => Object.values(Category).includes(c));
    return categories;
}

async function findClosestCategories(phrase: string): Promise<Category[]> {
    let categoryEmbeddings = readEmbeddings();
    let embedding = await getEmbedding(phrase);
    let distanceSimilarityDictioanry: { [key in Category]: Number } = {} as any;
    let cosineSimilarityDictionary: { [key in Category]: Number } = {} as any;
    for (let [category, categoryEmbedding] of Object.entries(categoryEmbeddings)) {
        distanceSimilarityDictioanry[category as Category] = getDistance(embedding, categoryEmbedding);
        cosineSimilarityDictionary[category as Category] = getCosineSimilarity(embedding, categoryEmbedding);
    }
    // // sort the dictionary by value
    let distanceSimilarityArray = Object.entries(distanceSimilarityDictioanry).sort((a, b) => Number(a[1]) - Number(b[1]));
    let cosineSimilarityArray = Object.entries(cosineSimilarityDictionary).sort((a, b) => Number(b[1]) - Number(a[1]));
    
    // print the top three of distance similarity
    // log("Distance Similarity")
    // for (let i = 0; i < 5; i++) {
    //     log(`${distanceSimilarityArray[i][0]}: ${distanceSimilarityArray[i][1]}`)
    // }

    // // // print the top three of cosine similarity
    // log("Cosine Similarity")
    // for (let i = 0; i < 5; i++) {
    //     log(`${cosineSimilarityArray[i][0]}: ${cosineSimilarityArray[i][1]}`)
    // }
    // return the categories from cosine similarity that have a similarity of more than 0.5
    let categories: Category[] = [];
    for (let [category, similarity] of cosineSimilarityArray) {
        if (Number(similarity) > 0.1) {
            categories.push(category as unknown as Category);
        }
    }
    // return only top 3
    return categories.slice(0, 3);
}

async function askLlama(sentence: string, filteredCategories: Category[]): Promise<Category[]> {
    // push procrastinating if it is not already in the list
    if (!filteredCategories.includes(Category.Procrastinating)) {
        filteredCategories.push(Category.Procrastinating);
    }
    if (!filteredCategories.includes(Category.Feeling)) {
        filteredCategories.push(Category.Feeling);
    }
    let prompt = `
    "${sentence}"\n
    Based on the sentence above and what the user is doing at the moment, classify the event into one or more of the following categories:`
    for (let category of filteredCategories) {
        prompt += `\n\t- ${category}: (${categoryDescriptions[category]})`    }
    prompt += `\n\tGive me the name of the categories as an array of strings and nothing else`
    // console.log(prompt);
    let output = await llamaComplete(prompt, {
        toLowerCase: true,
        model: "8b",
        temperature: 0.1
    })
    // console.log(output);
    
    let categories = output.replace(/[\[\]]/g, '').split(',').map((s: string) => s.trim())
    // captitalize the first letter of each category
    categories = categories.map((c: string) => c.charAt(0).toUpperCase() + c.slice(1));
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

async function checkCategory(sentence: string, expected: Category[]) {
    console.log(sentence);
    let actual = await getCategories(sentence);
    
    // console.log(`actual: ${toStr(actual)}, expected: ${toStr(expected)}`);
    // actual.push(Category.Feeling, Category.Procrastinating);
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
