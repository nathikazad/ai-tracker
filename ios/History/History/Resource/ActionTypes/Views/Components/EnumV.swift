import SwiftUI

#if os(iOS)
import WrappingHStack
#endif

struct EnumView: View {
    @State private var newItem = ""
    @Binding var items: [String]
    @Binding var changesToSave: Bool
    var body: some View {
        VStack {
            HStack {
                Text("Enums:")
                TextField("Add Enum", text: $newItem)
                Button(action: addItem) {
                    Image(systemName: "plus")
                }
            }
            .padding()
            
            #if os(iOS)
            WrappingHStack(items, id: \.self) { item in
                enumItemView(item)
            }
            .frame(minWidth: 250)
            .padding()
            #else
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                    ForEach(items, id: \.self) { item in
                        enumItemView(item)
                    }
                }
            }
            .padding()
            #endif
        }
    }
    
    @ViewBuilder
    private func enumItemView(_ item: String) -> some View {
        ZStack(alignment: .topTrailing) {
            Button(action: { deleteItem(item) }) {
                Text(item)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 16))
                .offset(x: 6, y: -6)
        }
        .padding(3)
    }
    
    private func addItem() {
        DispatchQueue.main.async {
            if !newItem.isEmpty {
                items.append(newItem)
                changesToSave = true
                newItem = ""
            }
        }
    }
    
    private func deleteItem(_ item: String) {
        DispatchQueue.main.async {
            items.removeAll { $0 == item }
            changesToSave = true
        }
    }
}
