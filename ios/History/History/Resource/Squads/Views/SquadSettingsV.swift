//
//  SquadSettingsV.swift
//  History
//
//  Created by Nathik Azad on 8/20/24.
//

import SwiftUI
struct SettingsTab: View {
    var body: some View {
        List {
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: .constant(true))
                Toggle("Sound", isOn: .constant(true))
                Toggle("Vibration", isOn: .constant(true))
            }
            
            Section(header: Text("Privacy")) {
                Toggle("Read Receipts", isOn: .constant(true))
                Toggle("Last Seen", isOn: .constant(false))
            }
            
            Section(header: Text("Chat")) {
                Picker("Theme", selection: .constant(0)) {
                    Text("Light").tag(0)
                    Text("Dark").tag(1)
                    Text("System").tag(2)
                }
                Picker("Font Size", selection: .constant(1)) {
                    Text("Small").tag(0)
                    Text("Medium").tag(1)
                    Text("Large").tag(2)
                }
            }
        }
    }
}
