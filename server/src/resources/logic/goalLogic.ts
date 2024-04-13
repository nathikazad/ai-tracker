import { getHasura } from "../../config";
import { complete3, complete4 } from "../../third/openai";
import { Frequency } from "../goal";
import { $ } from "../../generated/graphql-zeus";

export async function parseGoal(goal: string, user_id: number) {
    goal = goal.replace(/\n/g, "").replace(/"/g, '')
    let frequency: Frequency = {
        type: "periodic",
        timesPerDay: 1,
        period: 1
    };

    let name = await suggestName(goal);
    let classification = await classifyGoal(goal);
    

    if(classification.includes("periodic")) {
        console.log("insider periodic");
        frequency.type = "periodic"
        frequency.period = await extractPeriod(goal);
    } else if (classification.includes("weekly")) {
        console.log("inside weekly");
        delete frequency.period 
        frequency.type = "weekly"
        frequency.daysOfWeek = await extractDaysOfWeek(goal);
    }

    frequency.timesPerDay = await extractTimesPerDay(goal);
    frequency.preferredHours = await extractPreferredHours(goal) ?? frequency.preferredHours;
    frequency.duration = await extractDuration(goal) ?? frequency.duration


    console.log(`frequency ${JSON.stringify(frequency)}`);
    const chain = getHasura();
    let response = await chain.mutation({
        insert_goals_one: [{
            object: {
                name: name,
                nl_description: goal,
                user_id: user_id,
                frequency: $`frequency`
            }
        }, {
            id: true
        }]
    },
    {
        "frequency": frequency
    })
    return response.insert_goals_one?.id
}

async function classifyGoal(goal: string) {
    let prompt = `Your task is to classify a text as either 'periodic' or 'weekly' based on the scheduling details provided.
    Classify a text as 'periodic' if it mentions doing something every 'n' days, every day, or on a recurring basis that does not specify exact days of the week.
    Classify as 'weekly' if the text explicitly states certain days of the week (like Mondays, Wednesdays), weekdays, every weekday, or weekends.
    If the activity is scheduled once a week without specifying a day, classify it as 'periodic'.
    If no specific scheduling detail is provided, default to 'periodic'.
    For the input '${goal}', give me your answer`;

    let classification = (await complete3(prompt, 0.2, 20));
    console.log(`classification ${classification}`);
    return classification;
}

async function suggestName(goal: string) {
    let prompt = `Your purpose is to convert long term goals into short daily todos. Ignore all temporal information.
    example goal: I want to learn Spanish everyday for 30 minutes
    example todo: Learn Spanish
    give todo for the goal 
    "${goal}"
    Just give me single string as your response, it goes into next part of the program. So don't add anything extra`;
    let name = capitalizeWords(await complete3(prompt, 0.2, 20));
    console.log(`name ${name}`);
    return name;

    function capitalizeWords(str: String) {
        return str.split(" ").map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(" ");
    }
}

async function extractPeriod(goal: string) {
    let prompt = `I will give you a text and your purpose is to extract how often a something repeats in days.
        if text says everyday, then answer is 1
        if text says every other day, then answer is 2
        if text says every four days, then answer is 4
        if text says every week or weekly, then answer is 7
        for example statement "I want to do learn Spanish everyday" your response would be 1
        if you can't conclude any period from the text, then assume the answer is 1
        Give me single integer as your response
        "${goal}"`;
    let resp = await complete3(prompt, 0.2, 40);
    console.log(`period ${resp}`);
    return parseInt(resp);
}

async function extractTimesPerDay(goal: string) {
    let prompt = `Your task is to determine the daily frequency of an activity from the text. 
    If it mentions a specific number of times per day (e.g., 'twice a day'), return that number. 
    If it states a weekly schedule without daily repetition return 1, indicating it occurs once on each scheduled day. 
    If no frequency is specified, assume once per day and return 1. 
    Always provide a single integer as the answer
        Give me single integer as your response for the following text
        "${goal}"`;

    let resp = (await complete3(prompt, 0.2, 10));
    console.log(`timesPerDay ${resp}`);
    return parseInt(resp);
}

async function extractDaysOfWeek(goal: string) {
    let prompt = `Your purpose is to extract for me all the days of the week referred to in a text. 
        if text says every monday wednesday friday return ["monday", "wednesday", "friday"]
        if text says every weekday or except weekends return ["weekdays"]
        if text says weekends return ["weekends"]
        if no such information is give, return ["everyday"]
        classify the goal:
        "${goal}"
        Give me an array of strings as your response
        Don't add anything extra because goes into next part of the program. `;

    let resp = (await complete4(prompt, 0.2, 40));
    console.log(`days ${resp}`);
    const days = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday", "weekdays", "weekends", "everyday"];

    // Filter the response to ensure it only contains valid days and is formatted correctly
    let chosenDays = days.filter(day => resp.includes(day.toLowerCase()));

    return chosenDays
}

async function extractPreferredHours(goal: string) : Promise<string[] | null> {
    let prompt = `Your purpose is to extract the hour of a day from a text if it is there.
    if the text was "I want to do learn Spanish everyday at 7pm" your response would be "19:00"
    if the text was "I want to do learn Spanish everyday" your response would be "none"
    Either give me the hours in "hh:mm" format or "none" as your response, don't add anything else to response
        "${goal}"`;
    let resp = (await complete3(prompt, 0.2, 10));
    let hours = extractHours(resp);
    if (hours) {
        console.log(`preferredHours ${hours}`);
        return [hours]
    } else {
        prompt = `Your purpose is to extract the hour of a day from a text if it is there.
        if text says morning return "09:00"
        if text says afternoon return "12:00"
        if text says evening return "17:00"
        if text says night return "20:00"
        if text says midnight return "00:00"
        Either give me the hours in "hh:mm" format or "none" as your response, don't add anything else to response
            "${goal}"`;
        resp = (await complete3(prompt, 0.2, 10));
        let hours = extractHours(resp);
        if (hours) {
            console.log(`preferredHours ${hours}`);
            return [hours]
        }
    }
    return null
}

function extractHours(resp: string): string | null {
    const timeRegex = /(\d{2}:\d{2})/;
    const match = timeRegex.exec(resp);
    if (match) {
        return match[1]; 
    } else {
        return null;
    }
}

async function extractDuration(goal: string) {
    let prompt = `Your purpose is to extract the amount of time user wants to do certain activity from a text, but only if it is there.
    but do not give me the hour of the day in which activity takes place, only the total time to do something.
    if the text was "I want to do learn Spanish everyday for 30 minutes at 18:00" your response would be "00:30"
    if the text was "I want to do learn dance on mondays for an hour at 6am" your response would be "01:00"
    if the text was "I want to do learn Spanish everyday at 1pm" your response would be "none"
    Either give me the hours in "hh:mm" format or "none" as your response, don't add anything else to response
        "${goal}"`;
    let resp = (await complete3(prompt, 0.2, 10));
    return extractHours(resp);
}


