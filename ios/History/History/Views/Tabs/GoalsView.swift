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
        Group {
            if goalsController.goals.isEmpty {
                // Fullscreen message for no todos
                VStack {
                    Spacer()
                    Text("No Goals Yet")
                        .foregroundColor(.black)
                        .font(.title2)
                    Text("Create a goal by clicking the microphone below")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center) // This will center-align the text horizontally
                        .padding(.horizontal, 20)
                    Spacer()
                }
            } else {
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
