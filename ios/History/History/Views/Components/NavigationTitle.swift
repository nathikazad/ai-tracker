//
//  NavigationTitle.swift
//  History
//
//  Created by Nathik Azad on 4/11/24.
//

import SwiftUI
struct NavigationTitle: View {
    var title: String
    var onTap: () -> Void
    var body: some View {
            HStack {
                Spacer()
                Text(title)
                    .font(.title)
                    .foregroundColor(.primary)
                Button(action: onTap) {
                    Image(systemName: "chevron.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 6)
                        .foregroundColor(.primary) 
                }
                Spacer()
            }
            Spacer(minLength: 10)  // Adds space at the bottom, can help balance the title vertically
    }
}
