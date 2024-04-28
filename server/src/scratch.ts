
import { getHasura } from "./config";
import { $, events_bool_exp } from "./generated/graphql-zeus";
// import { $ } from "./generated/graphql-zeus";

interface SleepData {
    sleep: string[];
    wake: string[];
}

// const data: SleepData = {
//     sleep: ["22:30", "23:00", "21:45", "22:15", "23:30", "00:00", "21:00", "22:45"],
//     wake: ["6:30", "6:45", "6:15", "6:50", "7:00", "6:40", "6:45", "6:35"]
// };
// find the probablity of distribution of waking up before 6:30 given the sleep time
async function main() {
    await getStayEvents()
    // get correlation between wake time and office arrival
}
export async function getProbDistr() {
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
main()

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

export function toPST(dateString: string | undefined): string {
    if (!dateString) {
        return 'N/A';
    }
    dateString += 'Z'
    // Create a new Date object from the UTC timestamp
    const date = new Date(dateString);

    // Convert the date to PST by specifying the timeZone in toLocaleString options
    const pstDate = date.toLocaleString('en-US', {
        timeZone: 'America/Los_Angeles',
        hour12: true, // Use 12-hour format
        month: '2-digit',
        day: '2-digit',
        hour: 'numeric',
        minute: '2-digit',
        second: '2-digit'
    });

    // Replace commas with spaces and adjust AM/PM casing
    // return pstDate.replace(',', '').replace('AM', 'a.m.').replace('PM', 'p.m.');
    return pstDate
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



