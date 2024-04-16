
import { classifyText } from "../resources/logic"

async function main() {
    check("Hi my name is Nathik", "User is not asking me to do something and is also not being clear about what he is doing")
    check("I finished cooking", "User has finished doing something")
    check("I am going to pray now", "User is doing something now or is going to do something now or next.") 
    check("I am working on anki now", "User is doing something now or is going to do something now or next.") 
    check("I finished with tracking user location", "User has finished doing something") 
    check("Create a goal to wake up at 3am everyday", "User wants to create a goal")
    check("I dreamt that I was one with my dear Allah", "User wants to record a dream")
    check("Remind me to grab my speaker tomorrow", "User wants to create a reminder")
    check("Record this thought, If an apple falls off a tree it is called gravity", "User wants to record a thought")
    check("There are two birds in the sky", "User is not asking me to do something and is also not being clear about what he is doing")
    check("Why do I hate the guy twirling his hair?", "User is not asking me to do something and is also not being clear about what he is doing")
    check("I want to go skydiving", "User wants to do something in future")
    check("I want to go to the beach in the morning", "User wants to do something in future")
    check("I need to have a call with tito", "User wants to do something in future")
    check("I want to cook a curry on thursday", "User wants to do something in future")
    check("I am going to work on classification next", "User is doing something now or is going to do something now or next.")
    check("I have to go to trader joes in the evening", "User wants to do something in future")
}

async function check(text: string, expected: string) {
    let resp = await classifyText(text);
    if (expected !== resp) {
        console.log(`
        ${text}
            expected: ${expected}
            actual:   ${resp}`);
    }

}

main()
