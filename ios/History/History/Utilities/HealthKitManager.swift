import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    private(set) var authorized = false // Track authorization status
    
    private init() {
        self.checkAuthorization()
    }
    
    // Method to check current authorization status
    private func checkAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            self.authorized = false
            return
        }
        
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let status = healthStore.authorizationStatus(for: sleepType)
        
        switch status {
        case .sharingAuthorized:
            self.authorized = true
        case .sharingDenied, .notDetermined:
            self.authorized = false
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }
    
    // Request authorization to access HealthKit data asynchronously
    func requestAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw NSError(domain: "com.example.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device."])
        }
        
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let allTypes = Set([sleepType])
        
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: allTypes) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    self.authorized = success
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    // Retrieve sleep data from HealthKit asynchronously
    func retrieveSleepData() async throws -> [EventModel] {
        guard authorized else {
            throw NSError(domain: "com.example.healthkit", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit access not authorized."])
        }
        
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())! // 30 days ago
        let endDate = Date() // today
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        // Execute the query and manage the results asynchronously
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, result, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let results = result as? [HKCategorySample] {
                        let eventModels = results.map { sample -> EventModel in
                            EventModel(id: sample.hashValue, eventType:"sleep", startTime: sample.startDate, endTime: sample.endDate)
                        }
                        continuation.resume(returning: eventModels)
                    } else {
                        continuation.resume(returning: [])
                    }
                }
            }
            healthStore.execute(query)
        }
    }

}
