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
    var dateClickedAction: ((ActionModel) -> Void)?
    var fetchActions: () -> Void?
    var showTimeWithRespectToCurrentDate: Bool = false
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @ObservedObject private var timerManager = TimerManager.shared
    
    var body: some View {
        HStack {
//            if(level > 0) {
//                Rectangle()
//                    .frame(width: 4)
//                    .foregroundColor(Color.gray)
//                    .padding(.leading, CGFloat((level - 1) * 10))
//            }
            
            var formattedString = event.formatTimeWithSubscripts(date: state.currentDate)
            Text(showTimeWithRespectToCurrentDate ? formattedString : AttributedString(event.formattedTime))
                .font(.headline)
                .frame(width: verticalSizeClass == .compact ? 200 : 100, alignment: .leading)
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
                    if let remaining = timerManager.currentIds[event.id!] {
                        Text(timeString(from:remaining))
                    }
                }
                ActionDestination(event: event)
            }
            
        }
        .id(event.id)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(action: {
                print("Deleting \(event.id)")
                Task {
                    await ActionController.deleteActionModel(id: event.id!)
                    fetchActions()
                }
            }) {
                Image(systemName: "trash.fill")
            }
            .tint(.red)
            NavigationLink(destination: ActionTypeView(
                model: event.actionTypeModel
            )) {
                Image(systemName: "gear")
            }
        }
        
    }
}

struct ActionDestination: View {
    var event: ActionModel
    var body: some View {
        let destination = ShowActionView(actionModel: event)
        return AnyView(
            NavigationLink(destination: destination) {
                EmptyView()
            }
                .padding(.horizontal, 10)
                .opacity(0)
        )
        
    }
}

// super hacked up code to add subscripts
extension ActionModel {
    func formatTimeWithSubscripts(date: Date) -> AttributedString {
        let time = self.formattedTimeWithReferenceDate(date)
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


