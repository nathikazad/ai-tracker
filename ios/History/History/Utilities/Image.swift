//
//  Image.swift
//  History
//
//  Created by Nathik Azad on 5/30/24.
//

import SwiftUI

func saveImage(image: UIImage, imageLocation: String? = nil) -> String? {
    let data = image.jpegData(compressionQuality: 1) ?? image.pngData()
    guard let imageData = data else {
        print("Failed to get image data")
        return nil
    }
    
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    var finalLocation = UUID().uuidString
    if imageLocation != nil && !imageLocation!.isEmpty {
        finalLocation = imageLocation!
    }
    
    let filename = paths[0].appendingPathComponent("\(finalLocation).png")
    print("save location ", finalLocation)
    print("file name ", filename)
    
    do {
        try imageData.write(to: filename)
        return finalLocation
    } catch {
        print("Error saving image: \(error)")
        return nil
    }
}

func loadImage(location: String) -> UIImage? {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let filename = paths[0].appendingPathComponent("\(location).png")
    
    print("load location ", location)
    print("file name ", filename)
    return UIImage(contentsOfFile:filename.path)
}
