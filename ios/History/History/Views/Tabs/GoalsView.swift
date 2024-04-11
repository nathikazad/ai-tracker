//
//  GoalsView.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

struct GoalsView: View {
    @StateObject var goalsController = GoalsController()
    
    var body: some View {
        List {
            ForEach(goalsController.goals, id: \.id) { goal in
                VStack(alignment: .leading) {
                    Text(goal.name)
                        .font(.headline)
                    Text("\(goal.period)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            Task {
                await goalsController.fetchGoals()
                goalsController.listenToGoals()
            }
        }
        .onDisappear {
            goalsController.cancelListener()
            print("View has disappeared")
        }
    }
}


#Preview {
    GoalsView()
}
