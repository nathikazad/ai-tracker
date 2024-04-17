import { getHasura } from "../config";
import { complete3 } from "../third/openai";
import { insertInteraction } from "./interactions";
// import { parseGoal } from "./logic/goalLogic";




export async function parseUserRequest(text: string, user_id: number) {
    let classification = await classifyText(text)
    // console.log(`${text} \nClassification: ${classification}`)
    await insertInteraction(user_id, text, "event", {"classification": Classification[classification]});
    // let interaction_id = 
    // switch (classification) {
    //     case "todo":
    //         return "todo"
    //     case "goal":
    //         return parseGoal(text, user_id)
        // case Classification.Past:
            // return parseEvent(text, user_id, interaction_id)
    //     case "query":
    //         return "query"
    //     case "command":
    //         return "command"
        // default:
        //     console.log(classification)
        //     throw new Error("Invalid classification")
    // }
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
    prompt += `If yes, give me the number of the todo as an integer, if no, just say no`
    console.log(`prompt to find match \n\t${prompt}`);
    let resp = await complete3(prompt, 0.1);
    console.log(`matched response ${resp}`);
    let matchedIndex: number | null = extractNumber(resp);
    console.log(`extract number id ${matchedIndex}`);
    if (matchedIndex == null || matchedIndex < 0 || matchedIndex >= response.todos.length) {
        matchedIndex =  null
    }
    console.log(`matched id ${matchedIndex}`);
    let goal_id: number | undefined
    if (matchedIndex != null){
        var matchedTodo = response.todos[matchedIndex!];    
        goal_id = matchedTodo?.goal_id
        console.log("matchedTodo ", matchedTodo);
        if(matchedTodo.goal?.frequency?.timesPerDay == null) {
            await markTodoAsDone();
        } else {
            await incrementTargetNumber(matchedTodo); 
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

    async function markTodoAsDone() {
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
    }

    async function incrementTargetNumber(matchedTodo: any) {
        const targetTimesPerDay = matchedTodo.goal?.frequency?.timesPerDay!;
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
}

function extractNumber(text: string): number | null {
    // Regular expression to find the first sequence of digits
    const match = text.match(/\d+/);
    
    // If a match is found, convert it to a number and return
    if (match) {
        return parseInt(match[0], 10);
    }

    // Return null if no numbers are found
    return null;
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

// export async function classify(text: string) {
//     let prompt = `Here are some definitions
//     todo: is a one off thing that is scheduled only once for the future
//     goal: is something that person wants to repeatedly do in the future
//     event: is anything that happened in the past
//     query: is a question
//     command: is an instruction for an AI to execute
    
//     Classify the following statement as one of the above definitions
//     "${text}"`
//     console.log(prompt);
//     let response = await complete3(prompt, 0.1);
//     let chosenClass = "null";
//     ["todo", "goal", "event", "query", "command"].forEach((c) => {
//         if (response.toLowerCase().includes(c)) {
//             chosenClass = c
//         }
//     });
//     return chosenClass;
// }



// Define a generic classification function
// Generic function to handle classification
async function classify(text: string, options: string[], pathPrefix: string | null = null) {
    let prompt = `
    You are a smart assistant, your job is understand what a user is doing. 
    He will tell you things like "I something something" and you will interpret it
    Or he will ask you to do something as an imperative like "Do this" and you will interpret it
    These are the possible things user may want

    ${options.map((option, index) => `${index + 1}. ${option}`).join('\n')}

    Classify the following statement as one of the above, give me the number and state your reason
    "${text}"`;
    let response = await complete3(prompt, 0.1, 10);
    // console.log(response);
    
    let index = extractNumber(response);

    if (pathPrefix)
        return (index ? `${pathPrefix}.${index}` : `${pathPrefix}.none`) 
    else  
        return (index ? `${index}` : 'none');
}

async function processClassification(text: string, options: DecisionMaker[], currentPath: string | null = null) {
    const conditionLabels = options.map(opt => opt.condition);
    const path = await classify(text, conditionLabels as string[], currentPath);
    if (currentPath == null)
        return path.endsWith('none') || path.endsWith(`${conditionLabels.length}`) ?
           `${conditionLabels.length}` : path;
    else
        return path.endsWith('none') || path.endsWith(`${conditionLabels.length}`) ?
           `${currentPath}.${conditionLabels.length}` : path;
}

interface DecisionMaker {
    condition: string,
    nextConditions?: DecisionMaker[] | null,
    uniqueIdentifier?: Classification
}

export enum Classification {
    Past,
    Present,
    Dream,
    Thought,
    Goal,
    Todo,
    Reminder,
    Feeling,
    Unknown
}

function findUniqueId(condition: string, options: DecisionMaker[]): Classification {
    for (const option of options) {
        if (option.condition === condition) {
            return option.uniqueIdentifier ?? Classification.Unknown;
        }
        if (option.nextConditions) {
            const foundId = findUniqueId(condition, option.nextConditions);
            if (foundId) {
                return foundId;
            }
        }
    }
    return Classification.Unknown
}

export async function classifyText(text: string): Promise<Classification> {
    let options: DecisionMaker[] = [
        { condition: "User has finished doing something", uniqueIdentifier: Classification.Past},
        { condition: "User is doing something now or is going to do something now or next.", uniqueIdentifier: Classification.Present},
        { condition: "User is talking about a dream, thought, feeling, memory or incident he experienced", 
            nextConditions: [
                { condition: "User wants to record a dream", uniqueIdentifier: Classification.Dream },
                { condition: "User wants to record a thought", uniqueIdentifier: Classification.Thought },
                { condition: "User wants to record a feeling", uniqueIdentifier: Classification.Feeling },
                { condition: "User wants to record a memory", uniqueIdentifier: Classification.Past },
            ]},
        { condition: "User wants, has or needs to do something in the future",
            nextConditions:  [
                { condition: "User wants to create a goal", uniqueIdentifier: Classification.Goal },
                { condition: "User wants to do something in future", uniqueIdentifier: Classification.Todo },
                { condition: "User wants to create a reminder", uniqueIdentifier: Classification.Reminder },
                { condition: "Something else", uniqueIdentifier: Classification.Unknown }
            ]
        },
        { condition: "User is not asking me to do something and is also not being clear about what he is doing", uniqueIdentifier: Classification.Unknown}
    ]

    let currentOptions = options;
    let currentPath = null;
    let pathIndices = [];
    while (currentOptions) {
        currentPath = await processClassification(text, currentOptions, currentPath);
        pathIndices = currentPath.split('.').map(index => parseInt(index, 10) - 1); // Update path indices to zero-based
        const lastValidIndex = pathIndices[pathIndices.length - 1];

        // Check if we can continue navigating into nextConditions
        if (currentOptions[lastValidIndex] && currentOptions[lastValidIndex].nextConditions) {
            currentOptions = currentOptions[lastValidIndex].nextConditions!;
        } else {
            // If there are no further nextConditions, we conclude here
            return findUniqueId(currentOptions[lastValidIndex].condition, currentOptions);
        }
    }

    return Classification.Unknown;  // Default return if no conclusive path is found
}



// export async function classifyText(text: string) {
//     let firstLevelOptions = [
//         "User has finished doing something",
//         "User is doing something now or is going to do something now or next.",
//         "User wants, has or needs to do something in the future"
//     ];
//     let secondLevelOptions = [
//         "User wants to create a goal",
//         "User wants to create a todo",
//         "User wants to create a reminder",
//         "User wants to record a dream",
//         "User wants to record a thought",
//         "Something else"
//     ];
//     let thirdLevelOptions = [
//         "User wants to, needs to, or has to do something",
//         "Something else"
//     ];

//     let firstPath = await classify(text, firstLevelOptions);
//     if (!(firstPath.endsWith('none') || firstPath.endsWith('3'))) {
//         return firstPath
//     }
//     firstPath = "3"

//     let secondPath = await classify(text, secondLevelOptions, firstPath);
//     // console.log(`secondPath: ${secondPath}`);
//     if (!(secondPath.endsWith('none') || secondPath.endsWith('6'))) {
//         return secondPath
//     }
//     secondPath = "3.6"

//     let thirdPath = await classify(text, thirdLevelOptions, secondPath);
//     // console.log(thirdPath);
    
//     if (!(thirdPath.endsWith('none') || thirdPath.endsWith('2'))) {
//         return thirdPath
//     }
//     return "3.6.2"
// }