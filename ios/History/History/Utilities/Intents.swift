//
//  File.swift
//  History
//
//  Created by Nathik Azad on 3/19/24.
//

import Foundation
import AppIntents

struct RecordIntent: AppIntent {
    @Parameter(title: "Message")
    var text: String
    static let title: LocalizedStringResource = "Record in History"

  
    func perform() async throws -> some ProvidesDialog {
        return .result(dialog: "You said: \(self.text)")
    }
}

struct GetAddress: AppIntent {
    static let title: LocalizedStringResource = "Get Address"
    func perform() async throws -> some ReturnsValue<String>  {
        return .result(value: "https://ai-tracker-server-613e3dd103bb.herokuapp.com/convertAudioToInteractiondo you")
    }
}

struct HistoryShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: RecordIntent(),
                phrases: [
                    "Record in history",
                    "Record in \(.applicationName)",
                ],
                shortTitle: "Record in history",
                systemImageName: "mic.fill"
            ),
            AppShortcut(
                intent: GetAddress(),
                phrases: [
                    "Get Address",
                ],
                shortTitle: "Get Address",
                systemImageName: "doc.text"
            )
        ]
    }
}
