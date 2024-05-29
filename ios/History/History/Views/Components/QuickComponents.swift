//
//  HighPriorityButtonStyle.swift
//  History
//
//  Created by Nathik Azad on 5/23/24.
//

import SwiftUI

struct HighPriorityButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: PrimitiveButtonStyle.Configuration) -> some View {
        MyButton(configuration: configuration)
    }
    
    private struct MyButton: View {
        @State var pressed = false
        let configuration: PrimitiveButtonStyle.Configuration
        
        var body: some View {
            let gesture = DragGesture(minimumDistance: 0)
                .onChanged { _ in self.pressed = true }
                .onEnded { value in
                    self.pressed = false
                    if value.translation.width < 10 && value.translation.height < 10 {
                        self.configuration.trigger()
                    }
                }
            
            return configuration.label
                .opacity(self.pressed ? 0.5 : 1.0)
                .highPriorityGesture(gesture)
        }
    }
}
struct LabelledTextField: View {
    var name:String
    @Binding var value:String
    
    var body: some View {
        HStack {
            Text("\(name):")
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)
            TextField("\(name)", text: $value) {
                UIApplication.shared.minimizeKeyboard()
            }
        }
    }
}


extension UIApplication {
    func minimizeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}



