//
//  WorkView.swift
//  History
//
//  Created by Nathik Azad on 5/23/24.
//


import SwiftUI
struct WorkView: View {
    @State var event: EventModel? = nil
    @State var navigationStackId: Int? = nil
    @State var chatViewPresented: Bool = false
    var eventId: Int
    
    private func fetchData() {
        
        if(event == nil) {
            Task {
                let event = await EventsController.fetchEvent(id:eventId)
                DispatchQueue.main.async {
                    self.event = event
                }
            }
        }
    }

    var body: some View {
        List {
            Button(action: {
                print("Clicked plus")
                print("WorkView: boyd: \(state.navigationStackIds)")
                chatViewPresented = true
            }) {
                Image(systemName: "plus.circle")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
        }
        
        .onAppear {
            print("WorkView: onAppear: \(state.navigationStackIds)")
            navigationStackId = state.pushView()
            print("WorkView: onAppear: \(state.navigationStackIds)")
            fetchData()
        }
        .onDisappear {
            print("WorkView: onDisappear: \(state.navigationStackIds)")
            if let navigationStackId = navigationStackId {
                state.popView(id: navigationStackId)
            }
        }
        .navigationTitle("Working(\(String(eventId)))")
        .fullScreenCover(isPresented: $chatViewPresented) {
            ChatView {
                chatViewPresented = false
            }
        }
    }
}
