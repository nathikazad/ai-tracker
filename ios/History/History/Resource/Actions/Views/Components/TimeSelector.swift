//
//  TimeSelector.swift
//  History
//
//  Created by Nathik Azad on 8/3/24.
//

import Foundation
import SwiftUI
struct TimeInformationView: View {
    @Binding var startTime: Date
    @Binding var endTime: Date?
    let hasDuration: Bool
    let startTimeLabel: String
    let endTimeLabel: String
    @Binding var changesToSave: Bool

    var body: some View {
        VStack {
            DatePicker(
                startTimeLabel,
                selection: $startTime,
                displayedComponents: [.date, .hourAndMinute]
            )
            .onChange(of: startTime) { _ in changesToSave = true }

            if hasDuration {
                if endTime == nil {
                    HStack {
                        Text(endTimeLabel)
                        Spacer()
                        Button("Set") {
                            endTime = Date()
                            changesToSave = true
                        }
                        .padding(6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                    }
                } else {
                    DatePicker(
                        endTimeLabel,
                        selection: Binding(
                            get: { endTime ?? Date() },
                            set: {
                                endTime = $0
                                changesToSave = true
                            }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }
        }
    }
}
