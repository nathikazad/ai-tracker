//
//  Investor.swift
//  History
//
//  Created by Nathik Azad on 4/29/24.
//

import Foundation
extension ChatViewModel {
    func addInvestorMessage() {
        investorMessageCount += 1
        switch investorMessageCount {
        case 1: // How many hours have I slept in the last week?
            addMessage(message: "How many hours have I slept in the last week?", sender: .User)
            addMessage(message: "In the last week you have slept for 44 hours.", sender: .Maximus)
        case 2: // How many times did I meet my wake up goal of 6:30 am and getting 8 hours of sleep
            addMessage(message: "How many times did I meet my wake up goal of 6:30 am and getting 8 hours of sleep?", sender: .User)
            addMessage(message: "Except Sunday, you woke up before 6:30 am on every day.", sender: .Maximus)
            addChatContent(view: ScatterViewString(title: "Wake up time", data: [("M", 6.5), ("T", 7), ("W", 6.1), ("Th", 7.5), ("F", 7), ("Sa", 7.5), ("Sun", 7)]));
            addMessage(message: "Only sunday and thursday you slept for a minimum of 8 hours.", sender: .Maximus)
            addChatContent(view: BarView(title: "Hours slept", data: [("M", 6.5), ("T", 7), ("W", 6.1), ("Th", 7.5), ("F", 7), ("Sa", 7.5), ("Sun", 7)]));
        case 3: // Relationship between sleep time and wake up time?
            addMessage(message: "In general it seems that the later you go to sleep, the later you wake up.", sender: .Maximus)
            addMessage(message: "Here is a graph, demonstrating, the coorelation between your sleep hour on the x-axis and wake up hour on the y-axis.", sender: .Maximus)
            addChatContent(view: ScatterViewDoubles(title: "Sleep vs Wake", data: [(10, 6.5), (12, 7), (5, 6.1), (7, 7.5), (8, 7), (11.5, 7.5), (10, 7)]));
            addMessage(message: "Just assuming a simple linear relationship, for every hour later you sleep, you wake up roughly an hour later.", sender: .Maximus)
        case 4: // Effect of sleep time on meeting my goal of wake up time 6:30am
            addMessage(message: "As shown in the previous graph, assumping a linear relationship between your wake time and sleep time, when you sleep before 10:30pm you wake up before 6:30am", sender: .Maximus)
            addMessage(message: "Here is a probability distribution of waking up before 6:30am, given the sleep hour.", sender: .Maximus)
            addChatContent(view: BarView(title: "Bar Chart", data: [("A", 1), ("B", 2), ("C", 3), ("D", 4), ("E", 5)]));
            addMessage(message: "As you can see after 10:30pm, your chances of waking up before 6:30am, fall below 50%", sender: .Maximus)
        case 5: // Effect of wake up time on reaching the office
            addMessage(message: "There seems to be a linear relationship there as well, in general, you make it to office 2.5 hrs after you wake up", sender: .Maximus)
            addMessage(message: "Here is a graph, demonstrating, the coorelation between your wake up hour on the x-axis and office reach time on the y-axis.", sender: .Maximus)
            addChatContent(view: BarView(title: "Bar Chart", data: [("A", 1), ("B", 2), ("C", 3), ("D", 4), ("E", 5)]));
        case 6: // Effect of hours slept at number of hours worked
            addMessage(message: "There seems to be no coorelation between the hours worked and the number of hours worked", sender: .Maximus)
            addChatContent(view: BarView(title: "Bar Chart", data: [("A", 1), ("B", 2), ("C", 3), ("D", 4), ("E", 5)]));
        default:
            addMessage(message: "Investor messages: \(investorMessageCount)", sender: .Maximus)
        }
    }
}
