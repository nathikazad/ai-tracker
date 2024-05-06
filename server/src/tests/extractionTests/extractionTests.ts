import { log } from "console";
import { Category, Tense, extractMultipleEvents, extractTemporalInformation, extractTense } from "../../resources/logic/eventLogic";


async function main() {
    // await checkBreakdowns()
    // await checkTenses()
    await checkTemporals()
    // second check for feeling
    // check for cost
    // checkTense

}
main()

async function checkTemporals() {
    await checkTemporals("I will sleep for 8 hours", "6:30am", Category.Sleeping, Tense.Future, "6:30 am", "2:30 pm")
    await checkTemporals("I woke up at 6", "7:30am", Category.Sleeping, Tense.Past, null, "6:00 am")
    await checkTemporals("I had coffee at 11", "12:30pm", Category.Eating, Tense.Past, "11:00 am", null)
    await checkTemporals("I had coffee", "12:30pm", Category.Eating, Tense.Past, null, "12:30 pm")
    await checkTemporals("I slept from 8 to 10", "12:30pm", Category.Sleeping, Tense.Past, "8:00 am", "10:00 am")
    await checkTemporals("I slept at 10", "8:00am", Category.Sleeping, Tense.Past, "10:00 pm", "8:00 am")
    await checkTemporals("I slept at 10 and woke up at 6", "8:00am", Category.Sleeping, Tense.Past, "10:00 pm", "6:00 am")
    
    await checkTemporals("I am going to swim for 20 minutes", "2:22pm", Category.Exercising, Tense.Future, "2:22 pm", "2:42 pm")
    await checkTemporals("I plan to swim at 1pm, for 40 minutes", "11:30am", Category.Exercising, Tense.Future, "1:00 pm", "1:40 pm")
    await checkTemporals("I went to trader joe's and spent $100", "7:00pm", Category.Shopping, Tense.Past, null, "7:00 pm")
    await checkTemporals("I went to trader joe's at 6 and spent $100", "7:00pm", Category.Shopping, Tense.Past, "6:00 pm", "7:00 pm")
    await checkTemporals("I swam for 20 minutes, felt amazing", "12:40pm", Category.Exercising, Tense.Past, "12:20 pm", "12:40 pm")
    await checkTemporals("I will be with my dentist between 1pm to 2pm", "10am", Category.Meeting, Tense.Future, "1:00 pm", "2:00 pm")
    await checkTemporals("I was be with my dentist between 10am to 11am", "12:20pm", Category.Meeting, Tense.Past, "10:00 am", "11:00 am")
    async function checkTemporals(sentence: string, recordedTime: string, category: Category, tense: Tense, expectedStartTime: string | null, expectedEndTime: string | null) {
        let output = await extractTemporalInformation(sentence, recordedTime, [category], tense);
        if (output.start_time?.replace(/^0+(\d+)/, '$1') == expectedStartTime && output.end_time?.replace(/^0+(\d+)/, '$1') == expectedEndTime) {
            console.log("Matched");
        } else {
            console.log(`💣💣💣Mismatch: ${sentence}`); 
            if(output.start_time != expectedStartTime)
                console.log(`\tstart time actual: ${output.start_time} != expected: ${expectedStartTime}`);
            if(output.end_time != expectedEndTime)
                console.log(`\tend time actual: ${output.end_time} != expected: ${expectedEndTime}`);
        }
    }
}


async function checkTenses() {
    await checkTense("Woke up at 6am", Tense.Past)
    await checkTense("I prayed at 6.20", Tense.Past)
    await checkTense("I worked for an hour till like about 7.20", Tense.Past)
    await checkTense("Going to sleep now", Tense.Present)
    await checkTense("Will pray now", Tense.Present)
    await checkTense("Going to pray first", Tense.Future)
    await checkTense("Will have to wake up early tomorrow", Tense.Future)
    await checkTense("Want to wake up early tomorrow", Tense.Future)
    await checkTense("I have to see Sid in the evening", Tense.Future)
    await checkTense("I need to see Sid in the evening", Tense.Future)
    async function checkTense(sentence: string, expected: Tense) {
        let actual = await extractTense(sentence);
        if (actual === expected) {
            console.log("Matched");
        } else {
            console.log(`Mismatch: ${sentence} actual: ${actual} != expected: ${expected}`);
        }
    }
}

async function checkBreakdowns() {
    await checkBreakdown("Just got back from dancing, it wasn't so great, people were a bit too snobbish. I might have injured my knee, it hurts.", 3)
    await checkBreakdown("Woke up at 6am, I prayed at 6.20 and then afterwards I worked for an hour till like about 7.20 and then I spent the last 15 minutes on YouTube. And now I am going to get ready for work.", 5)
    await checkBreakdown("I practiced dancing from 10 to 10 40 p.m. and I was on YouTube for about 20-30 minutes. I finished praying Isha and now I'm going to sleep.", 4)
    await checkBreakdown("I spent $30 at TJ's", 1)
    await checkBreakdown("I went to TJ's and spent $100", 1)
    await checkBreakdown("I did absolutely nothing today", 1)
    await checkBreakdown("I spent the last 30 minutes on instagram", 1)
    await checkBreakdown("I drank a cup of coffee", 1)
    await checkBreakdown("I ran a mile", 1)
    await checkBreakdown("I did absolutely nothing for the last 50 minutes and scrolled around Instagram and YouTube", 1)
    async function checkBreakdown(sentence: string, expected: number) 
    {
        
        let events = await extractMultipleEvents(sentence);
        if (events.length === expected) {
            console.log("Matched");
        } else {
            console.log(events);
            console.log("💣💣💣 Mismatch");
        }
    }
}
