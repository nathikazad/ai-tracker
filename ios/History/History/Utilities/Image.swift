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
    return UIImage(contentsOfFile:filename.path)
}

func deleteImage(location: String) {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let filename = paths[0].appendingPathComponent("\(location).png")
    do {
        try FileManager.default.removeItem(at: filename)
    } catch {
        print("Error deleting image: \(error)")
    }
}

struct accessCameraView: UIViewControllerRepresentable {
    let closeCallback: (UIImage) -> Void
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self, closeCallback: closeCallback)
    }
}

// Coordinator will help to preview the selected image in the View.
class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: accessCameraView
    var closeCallback: (UIImage) -> Void
    init(picker: accessCameraView, closeCallback: @escaping (UIImage) -> Void) {
        self.picker = picker
        self.closeCallback = closeCallback
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.closeCallback(selectedImage)
        //        self.picker.isPresented.wrappedValue.dismiss()
    }
}

struct HorizontalImageView: View {
    let images: [String]
    @Binding var editMode:Bool
    @Binding var selectedImage: UIImage?
    let deleteAction: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(images, id: \.self) { imageLocation in
                    if let uiImage = loadImage(location: imageLocation) {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(8)
                                .padding(.top, 5)
                                .padding(.trailing, 5)
                                .onTapGesture {
                                    if !editMode {
                                        print("Image \(imageLocation) tapped")
                                        selectedImage = uiImage
                                    }
                                }
                            if editMode {
                                Button(action: {
                                    deleteAction(imageLocation)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .padding(2)
                                }
                                .symbolVariant(.circle.fill)
                                .foregroundStyle(.white,.yellow,.red)
                                .padding(.trailing, -3)
                                .padding(.top, -3)
                            }
                        }
                    }
                }
            }
        }
    }
}
