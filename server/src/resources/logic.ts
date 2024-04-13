import { getHasura } from "../config";
import { complete3 } from "../third/openai";
import { insertInteraction } from "./interactions";
import { parseGoal } from "./logic/goalLogic";




export async function parseUserRequest(text: string, user_id: number) {
    let classification = await classify(text)
    console.log(`${text} \nClassification: ${classification}`)
    let interaction_id = await insertInteraction(user_id, text, classification);
    switch (classification) {
        case "todo":
            return "todo"
        case "goal":
            return parseGoal(text, user_id)
        case "event":
            return parseEvent(text, user_id, interaction_id!)
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
        todos: [{
            where: { _and: [{ user_id: { _eq: user_id } }] }
        }, {
            id: true,
            name: true,
            goal_id: true,
            current_count: true,
            goal: {
                frequency: [{}, true]
            }
        }]
    });
    let prompt = `Do any of the following todos match the event "${event}"?\n`
    response.todos.forEach((todo, index) => {
        prompt += `${index}. ${todo.name}\n`;
    });
    prompt += "If yes, give me the number of the todo as an integer, if no, just say no"
    let resp = await complete3(prompt, 0.2);
    console.log(`matched response ${resp}`);
    
    let matchedIndex: number | null = parseInt(resp);
    if (isNaN(matchedIndex) || matchedIndex < 0 || matchedIndex >= response.todos.length) {
        matchedIndex =  null
    }
    let goal_id: number | undefined
    if (matchedIndex != null){
        var matchedTodo = response.todos[matchedIndex!];    
        goal_id = matchedTodo?.goal_id
        console.log("matchedTodo ", matchedTodo);
        if(matchedTodo.goal?.frequency?.timesPerDay == null) {
            await chain.mutation({
                update_todos_by_pk: [{
                    pk_columns: { id: matchedTodo.id },
                    _set: {
                        status: "done"
                    }
                }, {
                    id: true
                }]
            });
        } else {
            const targetTimesPerDay = matchedTodo.goal?.frequency?.timesPerDay!
            const currentCount = matchedTodo.current_count ?? 0;
            const newCount = currentCount + 1;
            const newStatus = newCount >= targetTimesPerDay ? "done" : "todo";
            await chain.mutation({
                update_todos_by_pk: [{
                    pk_columns: { id: matchedTodo.id },
                    _inc: {
                        current_count: 1
                    },
                    _set: {
                        status: newStatus
                    }
                }, {
                    id: true
                }]
            }); 
        }
    } else {
        console.log("no matches");
    }
    await chain.mutation({
        insert_events_one: [{
            object: {
                name: event,
                user_id: user_id,
                event_type: "root",
                goal_id: goal_id,
                interaction_id: interaction_id
            }
        }, {
            id: true
        }]
    })
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


