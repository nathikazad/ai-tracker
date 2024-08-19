// Main View
import SwiftUI
struct ActionTypeView: View {
    @State private var changesToSave: Bool = false
    @StateObject var model: ActionTypeModel
    var updateActionTypeCallback: ((ActionTypeModel) -> Void)?
    var deleteActionTypeCallback: ((Int) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    init(model: ActionTypeModel? = nil,
         updateActionTypeCallback: ( (ActionTypeModel) -> Void)? = nil,
         deleteActionTypeCallback: ( (Int) -> Void)? = nil) {
        _model = StateObject(wrappedValue: model ?? ActionTypeModel(name: "", meta: ActionTypeMeta(), staticFields: ActionModelTypeStaticSchema()))
        self.updateActionTypeCallback = updateActionTypeCallback
        self.deleteActionTypeCallback = deleteActionTypeCallback
    }
    init(id: Int) {
        _model = StateObject(wrappedValue: ActionTypeModel(id: id, name: "", meta: ActionTypeMeta(), staticFields: ActionModelTypeStaticSchema()))
    }
    
    var body: some View {
        Form {
            NameSection(name: $model.name, changesToSave: $changesToSave)
            MetaSection(model: model, changesToSave: $changesToSave)
            TimeSection(model: model, changesToSave: $changesToSave)
            DynamicFieldsSection(model: model, changesToSave: $changesToSave)
            if model.id != nil {
                ObjectRelationsSection(model: model)
                ChildConnectionSections(model: model, changesToSave: $changesToSave)
                ATVGoalsSection(model: model)
            }
            ActionButtons(model: model, changesToSave: $changesToSave, updateActionTypeCallback: updateActionTypeCallback, deleteActionTypeCallback: deleteActionTypeCallback, presentationMode: _presentationMode)
        }
        .navigationTitle("\(model.name)")
        .onAppear {
            Task {
                if let id = self.model.id,
                   let m = await ActionTypesController.fetchActionType(
                    userId: Authentication.shared.userId!,
                    actionTypeId: id,
                    withAggregates: true,
                    withObjectConnections: true
                   ) {
                    DispatchQueue.main.async { self.model.copy(m) }
                }
            }
        }
    }
}



