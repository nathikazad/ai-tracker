//
//  GoalsView.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

struct GoalsView: View {
    let goals = [
        ("Wake up at 5:30 am", "Everyday"),
        ("Cooking", "Sunday, Wednesday, Friday"),
        ("Workout", "Twice a day"),
        ("Pray", "Five times a day"),
        ("Call Mom", "Once a week"),
        ("Practice French", "Everyday 20 minutes"),
        ("Practice Dance", "Everyday 1 hour"),
        ("Sleep at 10:30 PM", "Everyday")
    ]
        
    var body: some View {
            NavigationView {
                List(goals, id: \.0) { activity, frequency in
                    VStack(alignment: .leading) {
                        Text(activity)
                            .font(.headline)
                        Text(frequency)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .navigationTitle("Goals")
            }
        }
    }


#Preview {
    GoalsView()
}
