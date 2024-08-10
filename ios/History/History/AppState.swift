//
//  AppState.swift
//  History
//
//  Created by Nathik Azad on 5/24/24.
//

import SwiftUI
import Combine

var state: AppState {
    return AppState.shared
}

class AppState: ObservableObject, MicrophoneDelegate {
    enum ChatViewToShow {
        case none, onBoard, normal, investor
    }

    enum SheetViewToShow {
        case none, settings, dailyQuotes, calendar
    }
    
    static let shared = AppState()
    @Published var currentDate = Calendar.current.startOfDay(for: Date())
    @Published var currentWeek = Date().getWeekBoundary
    @Published private(set) var chatViewToShow: ChatViewToShow = .none
    @Published private(set) var sheetViewToShow: SheetViewToShow = .none
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var isProcessingRecording: Bool = false
    @Published private(set) var navigationStackIds: [Int] = []
    @Published var inForeground = true
    @Published private(set) var parentEventId: Int? = nil
    
    private var microphone = Microphone()
    private let coreStatePublisher = PassthroughSubject<Void, Never>()
    private let recordingFinishedPublisher = PassthroughSubject<String, Never>()
    
    init() {
        microphone.delegate = self
    }
    
    func microphoneButtonClick(parse:Bool = true) {
        microphone.microphoneButtonClick(parse: parse, parentEventId: parentEventId)
    }
    
    func didStartRecording() {
        print("ViewController is aware: Recording has started")
        isRecording = true
        isProcessingRecording = false
    }
    
    func setParentEventId(_ id:Int?) {
        parentEventId = id
    }

    func didStopRecording(response: String) {
        recordingFinishedPublisher.send(response)
        print("ViewController is aware: Recording has stopped with response \(response)")
        isRecording = false
        isProcessingRecording = false
    }
    
    func didStartProcessingRecording() {
        isProcessingRecording = true
    }
    
    func pushView() -> Int {
        let newId = Set(1...100).subtracting(navigationStackIds).randomElement()!
        navigationStackIds.append(newId)
        return newId
    }
    
    func popView(id: Int) {
        if let index = navigationStackIds.firstIndex(of: id) {
            navigationStackIds.removeSubrange(index..<navigationStackIds.endIndex)
        }
    }

    
    func hideChat() {
        chatViewToShow = .none
    }
    
    func showChat(newChatViewToShow: ChatViewToShow) {
        print("AppState: showChat")
        chatViewToShow = newChatViewToShow
    }
    
    func hideSheet() {
        sheetViewToShow = .none
    }
    
    func showSheet(newSheetToShow: SheetViewToShow) {
        sheetViewToShow = newSheetToShow
    }
    
    func notifyCoreStateChanged() {
        coreStatePublisher.send()
    }
    
    func subscribeToCoreStateChanges(_ callback: @escaping () -> Void) -> AnyCancellable {
        return coreStatePublisher
            .sink(receiveValue: callback)
    }
    
    func subscribeToRecordingFinished(_ callback: @escaping (String) -> Void) -> AnyCancellable {
        return recordingFinishedPublisher
            .sink(receiveValue: callback)
    }
}
