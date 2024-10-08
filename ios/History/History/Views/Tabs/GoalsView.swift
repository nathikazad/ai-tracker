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
        VStack {
            // this text fixes a scroll bug
            Text("")
            .padding(.all, 0)
            .frame(maxWidth: .infinity)
            .opacity(0)
            
            Group {
                if goalsController.goals.isEmpty {
                    VStack {
                        Spacer()
                        Text("No Goals Yet")
                            .foregroundColor(.primary)
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
                                
                                Text(goal.nlDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                            }
                        }
                        .onDelete { indices in
                            indices.forEach { index in
                                let goalId = goalsController.goals[index].id
                                goalsController.deleteGoal(id: goalId)
                            }
                        }
                    }
                }
            }
            .onAppear {
                if(auth.areJwtSet) {
                    print("Goal View has appeared")
                    Task {
                        await goalsController.fetchGoals(userId: auth.userId!)
                    }
                    goalsController.listenToGoals(userId: auth.userId!)
                }
            }
            .onDisappear {
                goalsController.cancelListener()
                print("Goal View has disappeared")
            }
        }
    }
}


#Preview {
    GoalsView()
}
