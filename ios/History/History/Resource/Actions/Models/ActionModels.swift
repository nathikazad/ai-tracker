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

}
