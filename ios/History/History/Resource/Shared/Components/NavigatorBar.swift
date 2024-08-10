//
//  Navigator.swift
//  History
//
//  Created by Nathik Azad on 8/10/24.
//

import SwiftUI
struct NavigationBar<Content: View>: View {
    let content: Content
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                let contentTopPadding: CGFloat = verticalSizeClass == .compact ? 5 : -15
                content
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .padding(.top, contentTopPadding)
                    .padding(.horizontal, 10)
                    .background(Color(.systemBackground))
                
                let buttonTopPadding: CGFloat = verticalSizeClass == .compact ? 25 : 5
                Button(action: {
                    state.showSheet(newSheetToShow: .settings)
                }) {
                    Image(systemName: "line.3.horizontal")
                        .resizable()
                        .frame(width: 20, height: 15)
                        .padding(.horizontal, 20)
                        .padding(.top, buttonTopPadding)
                }
            }
            Divider()
        }
    }
}
