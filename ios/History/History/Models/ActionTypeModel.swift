//
//  ActionModel.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import Foundation

class ActionTypeModel: ObservableObject {
    var name: String
    @Published var meta: ActionTypeMeta
    var staticFields: ActionModelTypeStaticSchema
    @Published var dynamicFields: [String: Schema]
    @Published var internalObjects: [String: InternalObject]
    var aggregates: [String: Aggregate]
    var computed: [String: Any]
    var goals: [String: Any]
    
    var internalDataTypes: [String] {
        internalObjects.values.compactMap { $0.name }.sorted()
    }
    
    init(name: String,
         meta: ActionTypeMeta,
         staticFields: ActionModelTypeStaticSchema,
         dynamicFields: [String: Schema] = [:],
         computed: [String: Any] = [:],
         internalObjects: [String: InternalObject] = [:],
         aggregates: [String: Aggregate] = [:], goals: [String: Any] = [:]) {
        self.name = name
        self.meta = meta
        self.staticFields = staticFields
        self.dynamicFields = dynamicFields
        self.computed = computed
        self.internalObjects = internalObjects
        self.aggregates = aggregates
        self.goals = goals
    }
}

class ActionTypeMeta: ObservableObject {
    @Published var hasDuration: Bool
    var description: String?
    
    init(hasDuration: Bool = true, description: String? = nil) {
        self.hasDuration = hasDuration
        self.description = description
    }
}

class ActionModelTypeStaticSchema {
    var startTime: Schema?
    var endTime: Schema?
    var time: Schema?
    var parentId: Schema?
    
    init(startTime: Schema? = nil, endTime: Schema? = nil, time: Schema? = nil, parentId: Schema? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.time = time
        self.parentId = parentId
    }
}

class Schema {
    var name: String
    var dataType: String
    var description: String
    var array: Bool
    var enumValues: [String]
    var objectFields: [String: Schema]
    
    init( name: String, dataType: String, description: String,
          array: Bool = false,
          enumValues: [String] = [],
          objectFields: [String : Schema] = [:]) {
        self.dataType = dataType
        self.array = array
        self.description = description
        self.name = name
        self.enumValues = enumValues
        self.objectFields = objectFields
    }
}

class InternalObject: Observable {
    var name: String
    var description: String
    @Published var fields: [String: Schema]
    
    init(name: String, description: String, fields: [String : Schema]) {
        self.name = name
        self.description = description
        self.fields = fields
    }
}




