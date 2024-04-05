import { getHasura } from "../config";
import { complete3 } from "../third/openai";


export async function parse(text: string, user_id: number, interaction_id: number) {
    let classification = await classify(text)
    console.log(`${text} \nClassification: ${classification}`)
    switch (classification) {
        case "todo":
            return "todo"
        case "goal":
            return parseGoal(text, user_id)
        case "event":
            return parseEvent(text, user_id, interaction_id)
        case "query":
            return "query"
        case "command":
            return "command"
        default:
            console.log(classification)
            throw new Error("Invalid classification")
    }
}

export async function parseEvent(event: string, user_id: number, interaction_id: number) {
    // see if any todos can be checked off
    const chain = getHasura();
    let response = await chain.query({
        todo: [{
            where: { _and: [{ user_id: { _eq: user_id } }] }
        }, {
            id: true,
            name: true,
            goal_id: true,
            current_count: true,
            target_count: true
        }]
    });
    let prompt = `Do any of the following todos match the event "${event}"?\n`
    response.todo.forEach(async (todo: any) => {
        prompt += `${todo.name}\n`;
    }); 
    // prompt += "If yes, give me the number of the todo, if no, just say no"
    let resp = await complete3(prompt, 0.2);
    let matchedTodo: any = null;
    response.todo.forEach((todo: any) => {
        if (resp.includes(todo.name)) {
            matchedTodo = todo;
        }
    });
    console.log(prompt)
    console.log("matchedTodo ", matchedTodo);
    if (matchedTodo != null)
        await chain.mutation({
            update_todo_by_pk: [{
                pk_columns: { id: matchedTodo.id },
                _inc: {
                    current_count: 1
                },
                _set: {
                    status: (matchedTodo.current_count + 1) >= matchedTodo.target_count ? "done" : "todo"
                }
            }, {
                id: true
            }]
        });
    await chain.mutation({
        insert_events_one: [{
            object: {
                name: event,
                user_id: user_id,
                event_type: "root",
                goal_id: matchedTodo?.goal_id,
                interaction_id: interaction_id
            }
        }, {
            id: true
        }]
    })
    return matchedTodo;
}

export async function parseGoal(goal: string, user_id: number) {
    goal = goal.replace(/\n/g, "").replace(/"/g, '')
    let prompt = `Your purpose is to convert long term goals into short daily todos. Ignore all temporal information when creating todos
    example goal: I want to learn Spanish everyday for 30 minutes
    example todo: Learn Spanish
    give todo for the goal 
    "${goal}"
    
    Just give me single string as your response, it goes into next part of the program. So don't add anything extra`
    let name = (await complete3(prompt, 0.2)).replace(/\n/g, "").replace(/"/g, '').trim();
    
    prompt = `Your purpose is to extract repeating period in days  from a text, just give me a single integer as your response and nothing.
    for example statement "I want to do learn Spanish everyday" your response would be 1
    if it was weekly then 7, if it was monthly then 30.

    Just give me single integer as your response
    "${goal}"`
    let period = await complete3(prompt, 0.2);


    prompt = `Your purpose is to extract number of times to do something per day from a text, just give me a single integer as your response and nothing.
    for example statement "I want to do learn workout twice a day" your response would be 2,
    if it was once a day then 1, if it was 3 times a day then 3.
    Just give me single integer as your response
    "${goal}"`
    let target = await complete3(prompt, 0.2);


    const chain = getHasura();
    let response = await chain.mutation({
        insert_goal_one: [{
            object: {
                name: name,
                period: parseInt(period),
                nl_description: goal,
                user_id: user_id,
                target_number: parseInt(target)
            }
        }, {
            id: true
        }]
    })
    return response.insert_goal_one?.id
}

export async function test(goal: string) {
    // let prompt = `Your purpose is to convert long term goals into short daily todos. Ignore all temporal information when creating todos
    // example goal: I want to learn Spanish everyday for 30 minutes
    // example todo: Learn Spanish
    // give todo for the goal 
    // "${goal}"`
    let name = await complete3(goal);
    return name;
}
export async function classify(text: string) {
    let prompt = `Here are some definitions
    todo: is a one off thing that is scheduled only once for the future
    goal: is something that person wants to repeatedly do in the future
    event: is anything that happened in the past
    query: is a question
    command: is an instruction for an AI to execute
    
    Classify the following statement as one of the above definitions
    "${text}"`
    console.log(prompt); 
    let response = await complete3(prompt, 0.1);
    let chosenClass = "null";
    ["todo", "goal", "event", "query", "command"].forEach((c) => {
        if (response.toLowerCase().includes(c)) {
            chosenClass = c
        }
    });
    return chosenClass;
}   


