import { extractJson, llamaComplete } from "../../third/llama";
import { ASEvent, Category, Tense } from "./eventLogic"


export async function extractMetadata(event: ASEvent): Promise<ASEvent> {
    let metadata = {}
    console.log(`categories: ${event.categories}`)
    for (let category of event.categories) {
        switch (category) {
            case Category.Sleeping:
                break;
            case Category.WakingUp:
                event.categories = event.categories.filter(c => c !== Category.WakingUp)
                event.endTime = event.endTime ?? event.startTime;
                if(!event.categories.includes(Category.Sleeping)){
                    event.startTime = null
                    event.categories.push(Category.Sleeping)
                }
                break;
            case Category.Meeting:
                let people = await findPeople(event)
                let meetingInfo = await extractMeetingInfo(event)
                addData(category, {people, meetingInfo})
                break;
            case Category.Feeling:
                let feelingInfo = await extractFeelingInfo(event)
                addData(category, feelingInfo)
                break;
            case Category.Reading:
                let readingInfo = await extractReadingInfo(event)
                addData(category, readingInfo)
                break;
            case Category.Learning:
                // if(!event.categories.includes(Category.Dancing)){
                    let learningInfo = await extractLearningInfo(event)
                    addData(category, learningInfo)
                // }
                break;
            case Category.Eating:
                let foodInfo = await extractFoodInfo(event)
                addData(category, foodInfo)
                break;
            case Category.Cooking:
                let cookingInfo = await extractCookingInfo(event)
                addData(category, cookingInfo)
                break;
            case Category.Praying:
                let prayerInfo = await extractPrayerInfo(event)
                addData(category, prayerInfo)
                break;
            case Category.Shopping:
                let shoppingInfo = await extractionShoppingInfo(event)
                addData(category, shoppingInfo)
                break;
            case Category.Chores:
                let choresInfo = await extractChoresInfo(event)
                addData(category, choresInfo)
                break;
            case Category.Dancing:
                break;
            case Category.Working:
                // find the project
                break;
            case Category.Exercising:
                // find the exercise
                break;
            case Category.Distraction:
                let distractionInfo = await extractionDistractionInfo(event)
                addData(category, distractionInfo)
                break;
        }

        function addData(name:string, data:any) {
            metadata = {
                ...metadata,
                [name]: data
            }
        }
    }

    event.metadata = metadata
    return event
}

async function extractReadingInfo(event: ASEvent): Promise<any> {
    let description = `Tell me what book the user is reading`
    let fields = `
                name?: string; //name of the book,
                pagesCount?: number; //number of pages read
                currentPage?: number; //current page number
                currentChapter?: string; //current chapter`
    return extractInfo(event, description, fields)
}
async function extractPrayerInfo(event: ASEvent): Promise<any> {
    let description = `
        Tell me which prayer(s) the user is doing
        And tell me the count of prayers`
    let fields = 
            `name: string[]; //name of the prayers fajr/duhr/asr/maghrib/isha
             count: number; //number of prayers done, minimum 1, maximum 5`
    return extractInfo(event, description, fields)
}

async function extractCookingInfo(event: ASEvent): Promise<any> {
    let description = `Tell me what dish the user is cooking`
    let fields = "name?: string; //name of the dish"
    return extractInfo(event, description, fields)
}

async function extractChoresInfo(event: ASEvent): Promise<any> {
    let description = `Tell me what chore the user is doing`
    let fields = "name?: string; //name of the chore"
    return extractInfo(event, description, fields)
}

async function extractionShoppingInfo(event: ASEvent): Promise<any> {
    let description = `Tell me on where the user shopped and how much he spent. 
        If the user does not mention either of the field, then do not include that particular field`
    let fields = 
        `name?: string; //name of the place where user shopped
        amount?: number; //amount spent by the user. Don't include the currency information`
    return extractInfo(event, description, fields)
}

async function extractionDistractionInfo(event: ASEvent): Promise<any> {
    let description = `Tell me on what the user is distracting himself with`
    let fields = "name?: string; //name of the thing being used to get distracted"
    return extractInfo(event, description, fields)
}

async function extractLearningInfo(event: ASEvent): Promise<any> {
    let fields = "skill?: string; //name of the thing being learnt"
    return extractInfo(event, "Tell me what the user is learning about.", fields)
}

async function extractInfo(event: ASEvent, string:string, fields:string): Promise<any> {
    let prompt = `
    Given a sentence: "${event.sentence}"
    ${string}

    Output specs:
    Give me output as a json object, prefixed and suffixed by triple backticks
    with the fields 
        ${fields}
    '\n`

    let output = await llamaComplete(prompt, {
        toLowerCase: true,
        model: "70b",
        temperature: 0.1
    })

    let info = extractJson(output)
    return info
}

async function extractFeelingInfo(event: ASEvent): Promise<any> {
    let prompt = `
    Given a sentence: "${event.sentence}"
    If possible, how the user felt during the event.
    And give the feeling a score between -2 to 2. 
    Feelings like anger, sadness, fear, disgust, surprise should reduce the score.
    Feelings like happiness, joy, love, surprise should increase the score.

    Output specs:
    Give me output as a json object, prefixed and suffixed by triple backticks
    with the fields 
        name: string; name of the feeling
        score: integer; feeling score of the food between -2 to 2
    If there is not information to determine the values, then do not include the fields. 
    If the user does not describe how he felt, then do not include the fields
    '\n`

    let output = await llamaComplete(prompt, {
        toLowerCase: true,
        model: "70b",
        temperature: 0.1
    })
    console.log(`feeling output: ${output}`);

    let foodInfo = extractJson(output)
    return foodInfo
}

async function extractFoodInfo(event: ASEvent): Promise<any> {
    let prompt = `
    Given a sentence: "${event.sentence}"
    Tell me what food was mentioned in the sentence. 
    And give the food a health score between -2 to 2. 
    High artificial sugar content, high fat content, high salt content, high calorie content, high processed content, high cholesterol content, high saturated fat should reduce the health score.
    Vegetables, fruits, whole grains, lean protein, low fat, low sugar, low salt, low calorie, low processed, low cholesterol, low saturated fat should increase the health score.

    Output specs:
    Give me output as a json array, prefixed and suffixed by triple backticks and square brackets, 
    with each object in array having the fields 
        name: string; name of the food
        score: integer; health score of the food between -2 to 2
    If there is not information to determine the values, then do not include the fields
    '\n`

    let output = await llamaComplete(prompt, {
        toLowerCase: true,
        model: "70b",
        temperature: 0.1
    })

    let foodInfo = extractJson(output)
    return foodInfo
}

async function findPeople(event: ASEvent): Promise<any> {
    let prompt = `
    Given a sentence: "${event.sentence}"
    Give me names of all the people mentioned in the sentence. Only the ones whose names are mentioned explicitly.
    
    Output specs:
    Give me the names of the people as an array of strings and nothing else. 
    It is input to another program and it expects an array of strings
    '\n`

    let output = await llamaComplete(prompt, {
        toLowerCase: true,
        model: "70b",
        temperature: 0.1
    })


    // console.log(output);

    let names = output.replace(/[\[\]]/g, '').split(',').map((s: string) => s.trim())
    // captitalize the first letter of each category
    names = names.map((c: string) => {
        c = c.replace(/['"]+/g, '');
        // return c.trim().charAt(0).toUpperCase() + c.trim().slice(1);
        return c.trim();
    });



    // convert to array of dictionary with field name
    let people = names.map((name: string) => {
        return {
            name: name
        }
    })

    return people
}


async function extractMeetingInfo(event: ASEvent): Promise<any> {
    let prompt = `
    Given a sentence: "${event.sentence}"
    Tell me what kind of meeting it was.
    inperson/phone/online

    If it was inperson, tell me the location if is mentioned in the sentence.
    If users says speak or talk, then it is a phone meeting.
    Output specs:
    Give me output as only a json object, prefixed and suffixed by triple backticks, 
    with only the fields 
        meetingType: string; one of inperson/phone/online
        location?: string; only if meetingType is InPerson
        If there is not information to determine the values, then do not include the fields
    '\n`

    let output = await llamaComplete(prompt, {
        toLowerCase: true,
        model: "70b",
        temperature: 0.1
    })


    console.log(output);
    let meetingInfo = extractJson(output)
    return meetingInfo
}
