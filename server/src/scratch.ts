
import { getHasura } from "./config";
import { $, events_bool_exp } from "./generated/graphql-zeus";
import { toPST } from "./helper/time";
// import { $ } from "./generated/graphql-zeus";
import fs from 'fs'
import { extractJson, llamaComplete } from "./third/llama";


async function main() {
    // getEvents(1, "I am feeling something", 'feeling.json', 0.2)
    await classify("Going to sleep now.", "11:00pm")
    // await classify("I'm feeling pretty exhausted and have had a headache for the last hour. I think its because I skipped dinner yesterday, I have to investigate to see if it is a repeating pattern", "8:00am")
    // await classify2("I woke up 7am, went running for an hour, then had breakfast and went to work. I had a meeting at 10am and then I just finished lunch at 12pm", "12:10pm")
    // await classify2("I’m leaving office. I couldn’t get anything done. I feel so irritated.", "6pm")
    // await classify("I did the normal routine and also I added some pull-ups. I did 15 minutes on the treadmill at very low speed and also tried a balancing exercise with the left glute activated. It seemed pretty good. I'm going to keep doing both of these.", "2:00pm")
    // await classify2("Just got back from dancing, it wasn't so great, people were a bit too snobbish. I might have injured my knee, it hurts.", "11pm")
    // await classifyCategoryAndStatus("I just lost an hour trying to fix a stupid charts bug", "3:00pm")
    // await classifyCategoryAndStatus("I am going to swim for 20 minutes", "12:10pm")
    // await classifyCategoryAndStatus("I plan to swim at 1pm, for 40 minutes", "12:10pm")
    // await classifyCategoryAndStatus("I went to trader joe's and spent $100", "7:00pm")
    // await classifyCategoryAndStatus("I swam for 20 minutes, felt amazing", "12:40pm")
    // await classifyCategoryAndStatus("I will be with my dentist between 1pm to 2pm", "12:40pm")
    // await classifyCategoryAndStatus("I was be with my dentist between 10am to 11am", "12:40pm")
    // getDuration("I am going to swim for 20 minutes starting at 12:10pm");
    // let output = await llamaComplete(`Tell me something interesting`)
}
main()

interface Event {
    original: string;
    recordedAt: string;
    event: string;
    status: 'planning' | 'ongoing' | 'completed';
    category: 'sleeping' | 'feeling' | 'meeting' | 'reading' | 'consuming' | 'praying' | 'shopping' | 'dancing' | 'working' | 'working out' | 'other';
    start_time: string;
    duration: string;
}

async function classify(sentence: string, recordedTime:string) {
    console.log(`${sentence} at ${recordedTime}`);
    let prompt = `Convert the above sentence from user into a structured event.
    Give me output as json object, prefixed and suffixed by triple backticks, with only the fields status and category
    status: as one of following.
        completed: events that are completed signified with use of past tense.
        ongoing: event that are happening now or about to happen,
        planning: events that are planned
    category: as one of sleeping, dreaming, feeling, meeting, reading, dreaming, eating, praying, shopping, dancing, working, working out or other.`
    let output = await llamaComplete(`User said:'${sentence}' at time: ${recordedTime}.\n ${prompt}`)
    let event = {
        ...extractJson(output),
        original: sentence
    }
    // console.log(event);
    
    await getTemporalInformation(event, recordedTime);
    console.log("====================================");
}

async function getTemporalInformation(event: Event, recordedTime: string) {
    // console.log(`Event: ${event.category} status:${event.status}, ${event.description}`);
    let prompt = `Convert the above sentence from user into a structured event 
        Give me output as json object, prefixed and suffixed by triple backticks, with only the fields start_time and duration.
        start_time: the time event was started or will start, in 'hh:mm am/pm or null if not specified',
        duration: specify the time take for the event in 'hh:mm' or null if not specified,
        Give me output as json object(prefixed by triple backticks) with fields:
        `
    let fullPrompt = `User said '${event.original} at time ${recordedTime}'\n ${prompt}`
    // console.log(fullPrompt);
    let output = await llamaComplete(fullPrompt)
    let newEvent = {
        ...event,
        ...extractJson(output)
    };
    console.log(newEvent);
    
}

interface SleepData {
    sleep: string[];
    wake: string[];
}
async function getProbDistr() {
    let data = await getWakeAndSleepTimes();
    data.sleep = data.sleep.map(time => {
        const [hour, minute] = time.split(':');
        return (hour.length === 1 ? '0' : '') + hour + ':' + minute;
      });
    
    //   data.wake = data.wake.map(time => {
    //     const [hour, minute] = time.split(':');
    //     return (hour.length === 1 ? '0' : '') + hour + ':' + minute;
    //   });
    
    const sleepHours: string[] = [];
    for (let hour = 9; hour < 13; hour++) {
        for (let minute = 0; minute < 60; minute += 30) {
            sleepHours.push(`${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`);
        }
    }
    
    const probabilities = new Array(sleepHours.length).fill(0).map((_, index) => {
        const start = sleepHours[index];
        const end = sleepHours[index + 1] || "02:00";
        const sleepsInThisRangeArray = data.sleep.filter(sleep => {
            return isInBetween(sleep, start, end);
        })
        const sleepsInThisRange = sleepsInThisRangeArray.length;
        const sleepsInThisRangeAndWakesBeforeArray = data.sleep.filter((sleep, index) => {
            return isInBetween(sleep, start, end) && isInBetween(data.wake[index], "04:00", "5:30")
        })
        const sleepsInThisRangeAndWakesBefore = sleepsInThisRangeAndWakesBeforeArray.length;
        const probability = Math.ceil(sleepsInThisRangeAndWakesBefore / sleepsInThisRange * 100);
        // console.log(`${start} - ${end}: ${sleepsInThisRangeAndWakesBefore} ${sleepsInThisRange}  ${probability}`);
        return probability;
    });
    probabilities.forEach((probability, index) => {
        console.log(`${sleepHours[index]} - ${probability}%`);
    })
}

async function getWakeAndSleepTimes() {
    let resp = await getHasura().query({
        events: [
            {
                where: {
                    user_id: {
                        _eq: 1
                    },
                    event_type: {
                        _eq: "sleep"
                    }
                }
            },
            {
                start_time: true,
                end_time: true
            }
        ]
    })
    const data: SleepData = {
        sleep: [],
        wake: []
    };
    resp.events.forEach(event => {
        // console.log(event.start_time, event.end_time);
        event.start_time = toPST(event.start_time);
        event.end_time = toPST(event.end_time);
        // console.log(event.start_time, event.end_time);
        const sleepTime = event.start_time.match(/\b(\d{1,2}:\d{2})/)[1]
        const waketime = event.end_time.match(/\b(\d{1,2}:\d{2})/)[1]
        // console.log(sleepHour, sleepMinute, wakeUpHour, wakeUpMinute);
        
        data.sleep.push(sleepTime);
        data.wake.push(waketime);
    });
    return data;
}


function isInBetween(s: string, start: string, end: string) {
    // console.log("\t",s, start, end, s >= start, s < end);
    return s >= start && s < end;
}

async function getStayEvents() {
    let condtions:events_bool_exp = {
        metadata: {
            _contains: $`metadata`
        },
        user_id: {
            _eq: 1
        },
        event_type: {
            _eq: "stay"
        },
        _and: [{
            start_time: {
                _gte: new Date("2024-04-20").toISOString()
            }
        },
        {
            start_time: {
                _lt: new Date("2024-04-28").toISOString()
            }

        }]
}
    let resp = await getHasura().query({
        events_aggregate: [
            {
                where: condtions 
        },
        {
            aggregate: {
                count: [{}, true],
                sum: {
                    computed_cost_time: true
                }
            }
        }],
        events: [ {
            where: condtions
        },
        {
            start_time: true,
            end_time: true,
            metadata: [{}, true]
        }]
        
    }, {
        metadata: {
            "location": {
              "name": "Office"
            }
          }
    }
    )
    resp.events.forEach(event => {
        console.log(event.start_time, event.end_time, JSON.stringify(event.metadata));
    })
    return resp.events
}

    // console.log(resp.events_aggregate)



