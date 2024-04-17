
import { Classification, classifyText } from "../resources/logic"

async function main() {
    check("I am working on anki now", Classification.Present)
    check("Why do I hate the guy twirling his hair?", Classification.Unknown)
    check("I finished with tracking user location", Classification.Past)
    check("I am going to pray now", Classification.Present)
    check("I am going to work on classification next", Classification.Present)
    check("There are two birds in the sky", Classification.Unknown)
    check("I finished cooking", Classification.Past)
    check("Hi my name is Nathik", Classification.Unknown)
    check("I want to go skydiving", Classification.Todo)
    check("I need to have a call with tito", Classification.Todo)
    check("Record this thought, If an apple falls off a tree it is called gravity", Classification.Thought)
    check("I want to go to the beach in the morning", Classification.Todo)
    check("I dreamt that I was one with my dear Allah", Classification.Dream)
    check("Create a goal to wake up at 3am everyday", Classification.Goal)
    check("I want to cook a curry on thursday", Classification.Todo)
    check("I have to go to trader joes in the evening", Classification.Todo)
    check("Remind me to grab my speaker tomorrow", Classification.Reminder)
    check("Record this memory, I had a wonderful time with Yareni at the park. A dog chased me and I almost got bit", Classification.Past)
    check("I went to the market and bought some cookies", Classification.Past)
    check("I'm feeling a bit low", Classification.Feeling)
}

async function check(text: string, expected: Classification) {
    let resp = await classifyText(text);
    if (expected !== resp) {
        console.log(`
        ${text}
            expected: ${Classification[expected]}
            actual:   ${Classification[resp]}`);
    }

}

main()
