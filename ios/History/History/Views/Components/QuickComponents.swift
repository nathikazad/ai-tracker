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

struct CustomNavigationLink: View {
    var destination: GenericEventView
    var label: String
    var showArrow: Bool = true

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.body)
            if showArrow {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .background(NavigationLink(destination: destination, label: { EmptyView() }).opacity(0))
    }
}

struct BlackBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return InnerView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    private class InnerView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = UIColor(Color.black)
        }
        
    }
}


extension UIApplication {
    func minimizeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}



