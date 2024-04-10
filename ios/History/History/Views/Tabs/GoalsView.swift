//
//  GoalsView.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

struct GoalsView: View {
    @StateObject var goalsModel = GoalsModel()
    
    var body: some View {
        List {
            ForEach(goalsModel.goals, id: \.id) { goal in
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
                await goalsModel.fetchGoals()
                goalsModel.listenToGoals()
            }
        }
        .onDisappear {
            goalsModel.cancelListener()
            print("View has disappeared")
        }
    }
}


#Preview {
    GoalsView()
}
