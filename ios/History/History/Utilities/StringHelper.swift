//
//  StringHelper.swift
//  History
//
//  Created by Nathik Azad on 5/29/24.
//


import Foundation
import SwiftUI

extension Binding where Value == String? {
    func orEmpty() -> Binding<String> {
        Binding<String>(
            get: { self.wrappedValue ?? "" },
            set: { self.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}

func generateRandomString(_ len:Int = 5) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyz"
    return String((0..<len).map{ _ in letters.randomElement()! })
}

extension [String] {
    var joinWithAndAtEnd: String? {
        if count > 1 {
            let allButLast = dropLast().joined(separator: ", ")
            let last = last!
            return "\(allButLast) and \(last)"
        } else if let first = first {
            return first
        } else {
            return nil
        }
    }
}
