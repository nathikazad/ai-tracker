//
//  Popup.swift
//  History
//
//  Created by Nathik Azad on 5/25/24.
//

import SwiftUI

enum ShowInPopup {
    case createText
    case modifyText
    case modifyDate
    case modifyAssociation
    case create
    case none
}

struct PopupViewForPicker: View {
    var options: [String]
    var saveAction: (String) -> Void
    var closeAction: () -> Void
    @State var selectedOption:String = ""
    
    var body: some View {
        Group {
            PopupView(
                editComponent:
                    Group {
                        Picker("Options", selection: $selectedOption) {
                            ForEach(options, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    },
                saveAction: {
                    saveAction(selectedOption)
                },
                closeAction: closeAction
            )
        }
    }
}

struct PopupViewForText: View {
    var title: String
    @Binding var draftContent: String
    var closeAction: () -> Void
    var saveAction: () -> Void
    
    var body: some View {
        Group {
            PopupView(
                editComponent:
                    Group {
                        Text(title)
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

struct PopupViewForDate: View {
    @Binding var selectedTime: Date
    var saveAction: () -> Void
    var closeAction: () -> Void
    
    var body: some View {
        Group {
            PopupView(
                editComponent:
                    DatePicker("Select Time", selection: $selectedTime, displayedComponents: [.date, .hourAndMinute])
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
