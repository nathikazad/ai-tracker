//
//  Timer.swift
//  History
//
//  Created by Nathik Azad on 7/31/24.
//

import Foundation
import SwiftUI
import UserNotifications

class TimerManager: ObservableObject {
    static let shared = TimerManager()
    
    @Published var isTimerRunning = false
    @Published var currentId: Int? = nil
    @Published var remainingTime: TimeInterval = 0
    @Published var showCompletionAlert = false
    
    private var timer: Timer?
    private var endTime: Date?
    
    private init() {}
    
    func startTimer(duration: TimeInterval, timerId:Int) {
        timer?.invalidate()
        requestNotificationPermission()
        endTime = Date().addingTimeInterval(duration)
        isTimerRunning = true
        remainingTime = duration
        scheduleNotification(for: duration)
        currentId = timerId
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateRemainingTime()
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        remainingTime = 0
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timerNotification"])
    }
    
    private func updateRemainingTime() {
        guard let endTime = endTime else { return }
        remainingTime = max(endTime.timeIntervalSinceNow, 0)
        if remainingTime == 0 {
            showCompletionAlert = true
            cancelTimer()
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func scheduleNotification(for duration: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Timer Finished"
        content.body = "Your timer has completed!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        
        let request = UNNotificationRequest(identifier: "timerNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

struct TimerComponent: View {
    var timerId: Int
    @ObservedObject private var timerManager = TimerManager.shared
    @State private var selectedDuration: TimeInterval = 0
    
    var body: some View {
        VStack {
            HStack {
                if (timerManager.isTimerRunning && timerManager.currentId == timerId) {
                    HStack {
                        Text("Time Left:")
                        Spacer()
                        Text(timeString(from: timerManager.remainingTime))
                        
                        Button(action: {
                            timerManager.cancelTimer()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                else {
                    Picker("Set Timer:", selection: $selectedDuration) {
                        Text("None").tag(TimeInterval(0))
                        Text("Test").tag(TimeInterval(5))
                        Text("5 min").tag(TimeInterval(5 * 60))
                        Text("10 min").tag(TimeInterval(10 * 60))
                        Text("15 min").tag(TimeInterval(20 * 60))
                        Text("20 min").tag(TimeInterval(20 * 60))
                        Text("30 min").tag(TimeInterval(30 * 60))
                        Text("45 min").tag(TimeInterval(30 * 60))
                        Text("60 hour").tag(TimeInterval(60 * 60))
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedDuration) { oldValue, newValue in
                        if (newValue > 0) {
                            timerManager.startTimer(duration: newValue, timerId: timerId)
                            DispatchQueue.main.async {
                                selectedDuration = 0
                            }
                        }
                    }
                }
            }
        }
        .alert(isPresented: $timerManager.showCompletionAlert) {
            Alert(title: Text("Timer Completed"), message: Text("Your timer has finished!"), dismissButton: .default(Text("OK")))
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
