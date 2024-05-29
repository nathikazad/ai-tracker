//
//  NavigationButton.swift
//  History
//
//  Created by Nathik Azad on 5/28/24.
//

import SwiftUI
struct NavigationButton<Destination: View, Content: View>: View {
    let destination: Destination
    let content: () -> Content

    init(destination: Destination, @ViewBuilder content: @escaping () -> Content) {
        self.destination = destination
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                content()
            }
            NavigationLink(destination: destination) {
                EmptyView()
            }
            .padding(.horizontal, 10)
            .opacity(0)
        }
    }
}
