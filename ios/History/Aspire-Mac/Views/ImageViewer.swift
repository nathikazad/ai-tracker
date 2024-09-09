import SwiftUI

struct ImageViewer: View {
    @Binding var image: NSImage?
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("No image selected")
            }
            
            Button("Close") {
                isPresented = false
            }
            .padding()
        }
        .padding()
        .frame(width: 600, height: 400)
    }
}
