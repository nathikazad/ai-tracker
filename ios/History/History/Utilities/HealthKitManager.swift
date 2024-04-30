//
//  HealthKit.swift
//  History
//
//  Created by Nathik Azad on 4/24/24.
//

import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    private(set) var authorized = false
    
    private init() {
        self.checkAuthorization()
        self.setupSleepDataObserver()
    }
    
    // Method to check current authorization status
    func checkAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            self.authorized = false
            return
        }
        
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let status = healthStore.authorizationStatus(for: sleepType)
        print("😈😈😈😈😈😈 \(status)")
        switch status {
        case .sharingAuthorized:
            self.authorized = true
        case .sharingDenied, .notDetermined:
            self.authorized = false
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }
    
    // Request authorization to access HealthKit data
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "com.example.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device."]))
            return
        }
        
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let allTypes = Set([sleepType])
        
        healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { success, error in
            print("\(success) \(error)")
            self.authorized = success
            completion(success, error)
        }
    }
    
    // Retrieve sleep data from HealthKit
    func retrieveSleepData(startDate: Date, endDate: Date, completion: @escaping ([SleepData]) -> Void) {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, result, error in
            DispatchQueue.main.async {
                if let sleepSamples = result as? [HKCategorySample] {
                    print("HealthKitManager: retrieveSleepData: Original samples count \(sleepSamples.count)")
                    let consolidatedPeriods = self.consolidateSleepData(from: sleepSamples)
                    print("HealthKitManager: retrieveSleepData: Processed samples count \(consolidatedPeriods.count)")
                    completion(consolidatedPeriods)
                } else if let error = error {
                    print("Error retrieving sleep data: \(error.localizedDescription)")
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func setupSleepDataObserver() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
        let query = HKObserverQuery(sampleType: sleepType, predicate: nil) { query, completionHandler, error in
            if let error = error {
                print("HealthKitManager: setupSleepDataObserver: Observer query failed with error: \(error.localizedDescription)")
                return
            }
            
            print("HealthKitManager: setupSleepDataObserver:Health data changed, processing updates...")
            self.uploadSleepData()
            // You must call the completion handler when you're done.
            completionHandler()
        }
        
        // Execute the query
        healthStore.execute(query)
        
        // Enable background delivery
        healthStore.enableBackgroundDelivery(for: sleepType, frequency: .immediate) { success, error in
            if success {
                print("HealthKitManager: setupSleepDataObserver: Background delivery enabled")
            } else if let error = error {
                print("HealthKitManager: setupSleepDataObserver: Failed to enable background delivery: \(error.localizedDescription)")
            }
        }
    }
    
    struct SleepData {
        var start: Date
        var end: Date
    }
    
    private func consolidateSleepData(from sleepEntries: [HKCategorySample]) -> [SleepData] {
        let filteredEntries = sleepEntries
        let sortedEntries = filteredEntries.sorted { $0.startDate < $1.startDate }
        var consolidatedPeriods: [SleepData] = []
        
        for entry in sortedEntries {
            if let last = consolidatedPeriods.last, entry.startDate.timeIntervalSince(last.end) < 6 * 3600 {
                consolidatedPeriods[consolidatedPeriods.count - 1].end = max(last.end, entry.endDate)
            } else {
                consolidatedPeriods.append(SleepData(start: entry.startDate, end: entry.endDate))
            }
        }
        return consolidatedPeriods
    }
    
    func uploadSleepData(force:Bool = false) {
        let lastUploadTime = UserDefaults.standard.object(forKey: "lastUploadTime") as? Date ?? Date.distantPast
        print("HealthKitManager: uploadSleepData: \(lastUploadTime) \(Date().timeIntervalSince(lastUploadTime))")
            // Check if the time difference is more than 4 hours
        if !force && Date().timeIntervalSince(lastUploadTime) < (4*3600) {
            print("HealthKitManager: uploadSleepData: Skipping sleep upload")
            return
        } else {
            print("HealthKitManager: uploadSleepData: Uploading sleepdata")
        }
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())! // 1 week ago
        let endDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())! // 1 week ago
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd h:mm:ss a"
        dateFormatter.timeZone = TimeZone.current
        
        retrieveSleepData(startDate: startDate, endDate: endDate) { samples in
            Task {
                let sleepDataDicts = samples.map {
                    [
                        "sleep": $0.start.toUTCString,
                        "wake":  $0.end.toUTCString
                        
                    ]
                }
                let body: [String: Any] = ["sleepData": sleepDataDicts]
                do {
                    print("Send sleep data")
                    try await ServerCommunicator.sendPostRequest(to: uploadSleepEndpoint, body: body, token: Authentication.shared.hasuraJwt)
                    UserDefaults.standard.set(Date(), forKey: "lastUploadTime")
                } catch {
                    print("Error sending sleep data: \(error.localizedDescription)")
                    return
                }
            }
            
        }
        
    }
}





//}



//healthManager.checkAuthorization()
//getSleepData()



//        .filter { sample in
//        HKCategoryValueSleepAnalysis(rawValue: sample.value) == .inBed
//    }
