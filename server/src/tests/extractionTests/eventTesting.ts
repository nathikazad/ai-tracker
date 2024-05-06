// import { ASEvent, Category, Tense, extractEvents } from "../../resources/logic/eventLogic"



// async function main() {


//     let correct = await checkMorningRoutine()
//     console.log(correct)

//     async function check(actual: ASEvent[], expected: ASEvent[]): Promise<boolean> {
//         for (let i = 0; i < actual.length; i++) {
//             if (JSON.stringify(actual[i]) !== JSON.stringify(expected[i])) {
//                 console.log(`Mismatch: \n\ta:${JSON.stringify(actual[i])} \n\te:${JSON.stringify(expected[i])}`)
//                 return false
//             }
//         }
//         return true
//     }

//     async function checkMorningRoutine(): Promise<boolean> {
//         const expected: ASEvent[] = [
//             {
//                 categories: [Category.Sleeping],
//                 tense: Tense.Past,
//                 startTime: null,
//                 endTime: '06:00 am'
//             },
//             {
//                 categories: [Category.Praying],
//                 tense: Tense.Past,
//                 startTime: '06:20 am',
//                 endTime: null
//             },
//             {
//                 categories: [Category.Working],
//                 tense: Tense.Past,
//                 startTime: '06:20 am',
//                 endTime: '07:20 am'
//             },
//             {
//                 categories: [Category.Distraction],
//                 tense: Tense.Past,
//                 startTime: '12:15 pm',
//                 endTime: '12:30 pm'
//             },
//             {
//                 categories: [Category.Working],
//                 tense: Tense.Future,
//                 startTime: '12:30 pm',
//                 endTime: null
//             }
//         ]
//         let events = await extractEvents({
//             statement: "Woke up at 6am, I prayed at 6.20 and then afterwards I worked for an hour till like about 7.20 and then I spent the last 15 minutes on YouTube. And now I am going to get ready for work.",
//             recordedAt: "12:30pm"
//         })
//         return check(events, expected)  
//     }


//     async function checkGym(): Promise<boolean> {
//         let expected: ASEvent[] = [
//             {
//                 categories: [Category.Exercising],
//                 tense: Tense.Past ,
//                 startTime: '12:00 pm',
//                 endTime: '12:30 pm'
//             }
//         ]
//         let events = await extractEvents({
//             statement: "I went to the gym for 30 minutes",
//             recordedAt: "12:30pm"
//         })
//         return check(events, expected)
//     }
// }

// main()