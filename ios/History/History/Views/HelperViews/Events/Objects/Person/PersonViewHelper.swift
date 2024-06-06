//
//  PersonViewHelper.swift
//  History
//
//  Created by Nathik Azad on 5/31/24.
//

import SwiftUI

func openContact(_ contact: String, _ image: String) {
    let trimmedContact = contact.trimmingCharacters(in: .whitespacesAndNewlines)
    let numberCharacters = CharacterSet(charactersIn: "-+() ")
    switch image {
    case "mail":
        guard let url = URL(string: "mailto:\(trimmedContact)") else { return }
        UIApplication.shared.open(url)
    case "phone":
        guard let url = URL(string: "tel://\(trimmedContact)") else { return }
        UIApplication.shared.open(url)
    case "message":
        let phoneNumberEncoded = trimmedContact.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            // Create the URL to open the Messages app
        if let url = URL(string: "sms:\(phoneNumberEncoded)&body=") {
            // Check if the device can open the Messages app
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Cannot open Messages app.")
            }
        }
    case "whatsapp":
        let whatsappNumber = trimmedContact.components(separatedBy: numberCharacters).joined()
        guard let url = URL(string: "https://wa.me/\(whatsappNumber)") else { return }
                UIApplication.shared.open(url)
    case "linkedin", "instagram", "facebook":
        openUrl(trimmedContact)
    default:
        print("d")
    }
}

func openUrl(_ url:String) {
    var validURL = url
    if !validURL.hasPrefix("http://") && !validURL.hasPrefix("https://") {
        validURL = "http://\(validURL)"
    }
    guard let url = URL(string: validURL) else { return }
    UIApplication.shared.open(url)
}

func getImages(_ contact: String) -> [String] {
    var images:[String] = []
    let trimmedContact = contact.trimmingCharacters(in: .whitespacesAndNewlines)
    
    let numberCharacters = "-+() "
    if trimmedContact.contains("@") {
        images.append("mail")
    } else if trimmedContact.allSatisfy({ $0.isNumber || numberCharacters.contains($0)  }) { // Assuming it's a phone number
        images.append(contentsOf: ["phone", "whatsapp", "message"])
    } else { // Assuming it's a website
        if trimmedContact.contains("linkedin") {
            images.append("linkedin")
        } else if trimmedContact.contains("instagram") {
            images.append("instagram")
        } else if trimmedContact.contains("facebook") {
            images.append("facebook")
        }
    }
    return images
}
