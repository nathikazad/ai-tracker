//
//  ActionModels.swift
//  History
//
//  Created by Nathik Azad on 7/28/24.
//

import Foundation
//
//  EventModels.swift
//  History
//
//  Created by Nathik Azad on 5/28/24.
//

import Foundation

extension [ActionModel] {
    var sortEvents: [ActionModel] {
        return self.sorted { (event1, event2) -> Bool in
            let date1 = event1.startTime
            let date2 = event2.startTime
            return date1 < date2
        }
    }

    enum AggregateType {
        case sum
        case min
        case max
        case count
    }

    

//    func count(by fieldName: String) -> Int {
//        return self.reduce(0) { (acc, event) in
//            return acc + (event[fieldName] != nil ? 1 : 0)
//        }
//    }
//    func aggregate(aggregateType: AggregateType, fieldName: String?) -> ActionModel {
//        switch aggregateType {
//        case .sum:
//            return self.reduce(0) { (acc, event) in
//                return acc + event[fieldName].toInt ?? 0
//            }
//        case .min:
//            let filtered = self.filter { $0[fieldName] != nil }
//            return filtered.isEmpty ? [] : filtered.min { $0[fieldName]! < $1[fieldName]! }!
//        case .max:
//            let filtered = self.filter { $0[fieldName] != nil }
//            return filtered.isEmpty ? [] : filtered.max { $0[fieldName]! < $1[fieldName]! }!
//        case .count
//            return self.count
//        }
//    }
}


// example aggregate
// practice speaking once a day
// wake up at 6am everyday
// practice french 30 minutes a day
// practice dance 30 minutes a day
// pray five times a day
