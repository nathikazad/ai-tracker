//
//  StaticSchemaM.swift
//  History
//
//  Created by Nathik Azad on 8/14/24.
//

import Foundation
import SwiftUI
class ActionModelTypeStaticSchema: Observable, Codable {
    var startTime: Schema?
    var endTime: Schema?
    var time: Schema?
    var parentId: Schema?
    @Published var color: Color
    
    enum CodingKeys: String, CodingKey {
        case startTime, endTime, time, parentId, color
    }
    
    init(startTime: Schema? = nil, endTime: Schema? = nil, time: Schema? = nil, parentId: Schema? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.time = time
        self.parentId = parentId
        self.color = ASColor.colors.randomElement()?.0 ?? Color.clear
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startTime = try container.decodeIfPresent(Schema.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(Schema.self, forKey: .endTime)
        time = try container.decodeIfPresent(Schema.self, forKey: .time)
        parentId = try container.decodeIfPresent(Schema.self, forKey: .parentId)
        let colorName = try container.decodeIfPresent(String.self, forKey: .color) ?? "Clear"
        color = ASColor.stringToColor(colorName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(time, forKey: .time)
        try container.encode(parentId, forKey: .parentId)
        try container.encode(ASColor.colorToString(color), forKey: .color)
    }
}
