//
//  Navigator.swift
//  History
//
//  Created by Nathik Azad on 8/10/24.
//

import SwiftUI
struct NavigationBar<Content: View>: View {
    let content: Content
    @Binding var selectedTab: Tab
    @Binding var selectedTimelineType: TimelineType
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    init(selectedTab: Binding<Tab>, selectedTimelineType: Binding<TimelineType>, @ViewBuilder content: () -> Content) {
        self._selectedTab = selectedTab
        self._selectedTimelineType = selectedTimelineType
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                let contentTopPadding: CGFloat = verticalSizeClass == .compact ? 5 : -15
                content
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .padding(.top, contentTopPadding)
                    .padding(.horizontal, 10)
                    .background(Color(.systemBackground))
                
                let hstackTopPadding: CGFloat = verticalSizeClass == .compact ? -10 : -15
                HStack {
                    if selectedTab == .history {
                        leftButton
                    }
                    Spacer()
                    rightButton
                }
                .padding(.top, hstackTopPadding)
            }
            Divider()
        }
    }
    
    private var leftButton: some View {
        Button(action: {
            if selectedTimelineType == .day {
                selectedTimelineType = .week
            } else {
                selectedTimelineType = .day
            }
        }) {
            Image(systemName: "arrow.left.arrow.right")
                .resizable()
                .frame(width: 20, height: 20)
                .padding(.horizontal, 20)
                .padding(.top, buttonTopPadding)
        }
    }
    
    private var rightButton: some View {
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
    
    private var buttonTopPadding: CGFloat {
        verticalSizeClass == .compact ? 25 : 5
    }
}
