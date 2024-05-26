//
//  Popup.swift
//  History
//
//  Created by Nathik Azad on 5/25/24.
//

import SwiftUI

enum ShowInPopup {
    case text
    case date
    case none
}

struct popupViewForText: View {
    @Binding var draftContent: String
    var saveAction: () -> Void
    var closeAction: () -> Void
    
    var body: some View {
        Group {
            PopupView(
                editComponent:
                    Group {
                        Text("Edit Content")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        TextEditor(text: $draftContent)
                            .frame(minHeight: 50, maxHeight: 200) // Reduces the minimum height and sets a max height
                            .padding(4) // Reduces padding around the TextEditor
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray, lineWidth: 1) // Border for TextEditor
                            )
                    },
                saveAction: saveAction,
                closeAction: closeAction
            )
        }
    }
}

struct popupViewForDate: View {
    @Binding var selectedTime: Date
    var saveAction: () -> Void
    var closeAction: () -> Void
    
    var body: some View {
        Group {
            PopupView(
                editComponent:
                    DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .frame(maxHeight: 150),
                saveAction: saveAction,
                closeAction: closeAction
            )
        }
    }
}


private struct PopupView<EditComponent: View>: View {
    var editComponent: EditComponent
    var saveAction: () -> Void
    var closeAction: () -> Void
    var body: some View {
        VStack {
            editComponent
            Button(action: {
                saveAction()
            }) {
                Text("Save")
                    .foregroundColor(.primary)
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color("OppositeColor"))
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(width: 300)
        .overlay(
            Button(action: {
                closeAction()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            },
            alignment: .topTrailing
        )
    }
}
