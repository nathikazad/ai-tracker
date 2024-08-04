import SwiftUI
struct GoalsSection: View {
    @ObservedObject var aggregate: AggregateModel
    let dataType: String
    @Binding var changesToSave: Bool
    
    var body: some View {
        Section {
            List {
                ForEach(aggregate.metadata.goals.indices, id: \.self) { index in
                    ConditionView(index: index, dataType: dataType, condition: bindingForGoal(at: index))
                }
                .onDelete(perform: deleteGoals)
                
                if aggregate.metadata.goals.isEmpty {
                    AddNewGoalButton(aggregate: aggregate, changesToSave: $changesToSave)
                }
            }
            .navigationTitle("Track")
        }
    }
    
    private func bindingForGoal(at index: Int) -> Binding<Condition> {
        return Binding(
            get: { aggregate.metadata.goals[index] },
            set: { newValue in
                aggregate.metadata.goals[index] = newValue
                aggregate.objectWillChange.send()
                changesToSave = true
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
        let newGoal = Condition()
        aggregate.metadata.goals.append(newGoal)
        aggregate.objectWillChange.send()
        changesToSave = true
    }
}
