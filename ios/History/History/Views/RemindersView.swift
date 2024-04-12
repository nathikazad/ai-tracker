//
//  QuotesView.swift
//  History
//
//  Created by Nathik Azad on 4/11/24.
//

import Foundation
import SwiftUI

struct Quote: Identifiable {
    let id = UUID()
    let text: String
}

struct RemindersView: View {
    let quotes = [
        Quote(text: "Focus on the work that is in front of you, forget about the things you can't control. Trust in the Universe."),
        Quote(text: "Bias towards action, one step at a time."),
        Quote(text: "If tired or overwhelmed, work out, cook or do nothing. Don't scroll on insta, news or twitter."),
        Quote(text: "It is not ok to be sick. It is not ok to be poor. Seek health, seek abundance, the Universe is infinite, there is enough for everyone."),
        Quote(text: "You are always learning and experimenting to find out what people want, that is how you earn your sustenance from them.")
    ]
    
    var body: some View {
            NavigationView {
                List {
                    ForEach(quotes) { quote in
                        VStack {
                            Text("\"\(quote.text)\"")
                                .font(.body)
                        }
                        .padding(.vertical, 0)
                        .listRowSeparator(.hidden)
                    }
                }
                .navigationTitle("Reminders")
            }
        }
}

struct QuotesView_Previews: PreviewProvider {
    static var previews: some View {
        RemindersView()
    }
}
