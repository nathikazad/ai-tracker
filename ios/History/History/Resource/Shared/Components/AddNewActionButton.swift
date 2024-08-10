//
//  AddNewActionButton.swift
//  History
//
//  Created by Nathik Azad on 8/10/24.
//

import SwiftUI
struct AddNewActionButton: View {
    let verticalSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        NavigationLink(destination: ListActionsTypesView(listActionType: .takeToActionView)) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 178/255, green: 72/255, blue: 49/255),
                        Color(red: 222/255, green: 152/255, blue: 64/255)
                    ]),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .clipShape(Circle())
                
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .padding(buttonSize * 0.3)
                    .foregroundColor(.white)
            }
            .frame(width: buttonSize, height: buttonSize)
            .shadow(radius: 4)
        }
    }
    
    private var buttonSize: CGFloat {
        verticalSizeClass == .compact ? 40 : 60
    }
}
