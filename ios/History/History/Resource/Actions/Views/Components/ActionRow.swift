//
//  ActionRow.swift
//  History
//
//  Created by Nathik Azad on 7/28/24.
//

import Foundation

//
//  EventRow.swift
//  History
//
//  Created by Nathik Azad on 5/25/24.
//
import SwiftUI
struct ActionRow: View {
    var event: ActionModel
    @Binding var reassignParentForId: Int?
    @Binding var expandedEventIds: Set<Int>
    var dateClickedAction: ((ActionModel) -> Void)?
    var level: Int = 0
    var showTimeWithRespectToCurrentDate: Bool = false
    
    var body: some View {
        HStack {
            if(level > 0) {
                Rectangle()
                    .frame(width: 4)
                    .foregroundColor(Color.gray)
                    .padding(.leading, CGFloat((level - 1) * 10))
            }
            Text(formatTime(event))
                .font(.headline)
                .frame(width: 100, alignment: .leading)
                .onTapGesture {
                    print("tapped")
                    dateClickedAction?(event)
                }
            Divider()
            
            ZStack(alignment: .leading) {
                HStack {
                    Text("\(event.actionTypeModel.name) \(event.toString ?? "") (\(String(event.id ?? 0)))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
//                    EventButtonsView(event: event, reassignParentForId: $reassignParentForId, expandedEventIds: $expandedEventIds)
                }
//                EventDestination(event: event)
            }
            
        }
        .id(event.id)
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button(action: {
                print("Clicked mic on \(event.id)")
                state.setParentEventId(event.id)
                state.microphoneButtonClick()
            }) {
                Image(systemName: "mic.fill")
            }
            Button(action: {
                print("Clicked chat on \(event.id)")
                state.setParentEventId(event.id)
                state.showChat(newChatViewToShow: .normal)
            }) {
                Image(systemName: "message.fill")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(action: {
                print("Deleting \(event.id)")
//                EventsController.deleteEvent(id: event.id)
            }) {
                Image(systemName: "trash.fill")
            }
            .tint(.red)
            Button(action: {
                print("Clicked rearrange on \(event.id)")
                reassignParentForId = event.id
            }) {
                Image(systemName: "arrow.up.and.line.horizontal.and.arrow.down")
            }
        }
    }
    
    // super hacked up code to add subscripts
    private func formatTime(_ event: ActionModel) -> AttributedString {
        if !showTimeWithRespectToCurrentDate {
            return AttributedString(event.formattedTime)
        }
        let time = event.formattedTimeWithReferenceDate(state.currentDate)
        let pattern = "(\\+\\d+|-\\d+)"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(time.startIndex..<time.endIndex, in: time)
        let matches = regex.matches(in: time, options: [], range: range)
        if matches.count > 0 {
            var arr: [String] = []
            var index = 0
            for match in matches {
                let start = time.index(time.startIndex, offsetBy: index)
                let midone = time.index(time.startIndex, offsetBy: match.range.lowerBound - 1)
                let midtwo = time.index(time.startIndex, offsetBy: match.range.lowerBound)
                let end = time.index(time.startIndex, offsetBy: match.range.upperBound-1)
                arr.append(time[start...midone].lowercased())
                arr.append(time[midtwo...end].lowercased())
                index = match.range.upperBound
            }
            if(index < time.count) {
                let start = time.index(time.startIndex, offsetBy: index)
                let mid = time.index(time.startIndex, offsetBy: time.count-1)
                arr.append(time[start...mid].lowercased())
            }
            let attributedString = NSMutableAttributedString()
            for i in 0..<arr.count {
                if arr[i].starts(with: "+") || arr[i].starts(with: "-") {
                    attributedString.append(NSAttributedString(string: " " + arr[i], attributes: [
                        .baselineOffset: 16,
                        .font: UIFont.systemFont(ofSize: 14),
                    ]))
                } else {
                    attributedString.append(NSAttributedString(string: arr[i]))
                }
            }
            return AttributedString(attributedString)
        }
        return AttributedString(time)
    }
}


