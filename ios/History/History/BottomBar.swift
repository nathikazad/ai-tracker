//
//  MicButtonView.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import SwiftUI
import AVFoundation

struct BottomBar: View {
    @State private var isListening = false
    @State private var text = "Press the button and start speaking"
//    @StateObject var speechRecognizer = SpeechRecognizer()
    @StateObject var audioRecorder = AudioRecorder();
    @StateObject var audioUploader = AudioUploader()
    
    var body: some View {
        HStack {
//            Text(isListening ? speechRecognizer.transcript : text)
            Text(text)
                .font(.title)
                .padding()
            
            Spacer()
            Button(action: {
                if isListening {
                    Task.init { await stopListening() }
                } else {
                    startListening()
                }
                isListening.toggle()
            }) {
                Image(systemName: isListening ? "stop.fill" : "mic.fill")
                    .font(.largeTitle)
                    .padding()
            }
        }
    }
    
    private func startListening() {
        audioRecorder.startRecording();
//        speechRecognizer.resetTranscript()
//        speechRecognizer.startTranscribing()
    }
    
    private func stopListening() async {
        
        let fileUrl = await audioRecorder.stopRecording()
        print("Audio was saved in file: \(fileUrl.path)")
        await audioRecorder.playRecording()
//        audioUploader.uploadAudioFile(at: fileUrl, to: "http://100.87.137.10:3000/upload")
//        speechRecognizer.stopTranscribing()
//        print(speechRecognizer.transcript)
    }
    
    func playAudioFile(at fileUrl: URL) {
        var audioPlayer: AVAudioPlayer?
       

       do {
           audioPlayer = try AVAudioPlayer(contentsOf: fileUrl)
           audioPlayer?.prepareToPlay()
           audioPlayer?.play()
       } catch {
           print("Could not load file: \(error.localizedDescription)")
       }
   }
    
    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
