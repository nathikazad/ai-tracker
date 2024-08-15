import SwiftUI
struct GoalsSection: View {
    @ObservedObject var aggregate: AggregateModel
    let dataType: DataType
    @Binding var changesToSave: Bool
    
    var body: some View {
        List {
            ForEach(aggregate.metadata.goals.indices, id: \.self) { index in
                GoalView(index: index, dataType: dataType, window: $aggregate.metadata.window, goal: bindingForGoal(at: index))
            }
            .onDelete(perform: deleteGoals)
            
            if aggregate.metadata.goals.isEmpty {
                AddNewGoalButton(aggregate: aggregate, changesToSave: $changesToSave)
            }
        }
    }
    
    private func bindingForGoal(at index: Int) -> Binding<Goal> {
        return Binding(
            get: { aggregate.metadata.goals[index] },
            set: { newValue in
                aggregate.metadata.goals[index] = newValue
                changesToSave = true
                Task { @MainActor in
                    aggregate.objectWillChange.send()
                }
            }
        )
    }
    
    private func deleteGoals(at offsets: IndexSet) {
        aggregate.metadata.goals.remove(atOffsets: offsets)
        changesToSave = true
    }
}

struct AddNewGoalButton: View {
    @ObservedObject var aggregate: AggregateModel
    @Binding var changesToSave: Bool
    
    var body: some View {
        Button(action: addNewGoal) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add New Goal")
            }
        }
        .foregroundColor(.blue)
    }
    
    private func addNewGoal() {
        let newGoal = Goal()
        aggregate.metadata.goals.append(newGoal)
        aggregate.objectWillChange.send()
        changesToSave = true
    }
}
