//
//  MicButtonView.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import SwiftUI
import AVFoundation

//struct BottomBar: View {
//    @State private var isListening = false
//    @State private var text = "Press the button and start speaking"
//    @StateObject var audioRecorder = AudioRecorder();
//    
//    var body: some View {
//        HStack {
//            Text(text)
//                .font(.title)
//                .padding()
//            
//            Spacer()
//            Button(action: {
//                if isListening {
//                    Task.init { await stopListening() }
//                } else {
//                    Task.init { await startListening() }
//                }
//                isListening.toggle()
//            }) {
//                Image(systemName: isListening ? "stop.fill" : "mic.fill")
//                    .font(.largeTitle)
//                    .padding()
//            }
//        }
//    }
//    
//    private func startListening() async {
//        await audioRecorder.startRecording();
//    }
//    
//    private func stopListening() async {
//        let fileUrl = await audioRecorder.stopRecording()
//        do {
//            let data = try AudioUploader().uploadAudioFile(at: fileUrl, to: "https://ai-tracker-server-613e3dd103bb.herokuapp.com/convertAudioToInteraction")
//            if let data = data, let responseText = String(data: data, encoding: .utf8) {
//                print("Received text: \(responseText)")
//            }
//        } catch {
//            print("Some uploading error")
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
