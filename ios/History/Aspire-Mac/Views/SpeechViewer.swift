//
//  SpeechViewer.swift
//  Aspire-Mac
//
//  Created by Nathik Azad on 9/13/24.
//

import Foundation
import SwiftUI
import Speech
import AVFoundation

struct SpeechViewer: View {
    @StateObject private var viewModel = TranscriptionViewModel()
    
    var body: some View {
        VStack {
            Button("Choose Audio File") {
                viewModel.chooseFile()
            }
            .padding()
            
            if viewModel.isTranscribing {
                ProgressView()
                    .padding()
            }
            
            ScrollView {
                Text(viewModel.transcribedText)
                    .padding()
            }
        }
        .frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity, minHeight: 200, idealHeight: 300, maxHeight: .infinity)
    }
}

class TranscriptionViewModel: ObservableObject {
    @Published var transcribedText = ""
    @Published var isTranscribing = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    func chooseFile() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.audio]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        
        openPanel.beginSheetModal(for: NSApp.keyWindow!) { response in
            if response == .OK, let url = openPanel.url {
                self.transcribeAudio(url: url)
                let documentsDirectory =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let aacFileURL = documentsDirectory.appendingPathComponent("output.m4a")

                convertWAVToCompressedAAC(inputURL: url, outputURL: aacFileURL) { success, error, outputURL, fileSize in
                    if success {
                        if let outputURL = outputURL {
                            print("Conversion successful! File saved at: \(outputURL.absoluteString)")
                            if let fileSize = fileSize {
                                print("File size: \(fileSize) bytes")
                            }
                        }
                    } else if let error = error {
                        print("Conversion failed with error: \(error)")
                    }
                }
            }
        }
    }
    
    private func transcribeAudio(url: URL) {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            requestSpeechRecognitionPermission()
            return
        }
        
        isTranscribing = true
        transcribedText = "Transcribing..."
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        speechRecognizer?.recognitionTask(with: request) { [weak self] (result, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.transcribedText = "Error: \(error.localizedDescription)"
                    self.isTranscribing = false
                } else if let result = result {
                    self.transcribedText = result.bestTranscription.formattedString
                    if result.isFinal {
                        self.isTranscribing = false
                    }
                }
            }
        }
    }
    
    private func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.transcribedText = "Speech recognition authorized. You can now choose an audio file."
                } else {
                    self.transcribedText = "Speech recognition not authorized."
                }
            }
        }
    }
}



func convertWAVToCompressedAAC(inputURL: URL, outputURL: URL, completion: @escaping (Bool, Error?, URL?, UInt64?) -> Void) {
    // Prepare the input audio file
    let inputFile: AVAudioFile
    do {
        inputFile = try AVAudioFile(forReading: inputURL)
    } catch {
        completion(false, error, nil, nil)
        return
    }

    // Define the output format (AAC, Mono, 32 kbps, 16 kHz)
    let outputFormat = AVAudioFormat(settings: [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVSampleRateKey: 16000,           // 16 kHz sample rate
        AVNumberOfChannelsKey: 1,         // Mono audio
        AVEncoderBitRateKey: 32000        // 32 kbps bitrate
    ])

    guard let format = outputFormat else {
        completion(false, NSError(domain: "AudioConversionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid output format."]), nil, nil)
        return
    }

    // Prepare the output audio file
    let outputFile: AVAudioFile
    do {
        outputFile = try AVAudioFile(forWriting: outputURL, settings: format.settings)
    } catch {
        completion(false, error, nil, nil)
        return
    }

    // Set up an audio converter to handle the conversion
    let converter = AVAudioConverter(from: inputFile.processingFormat, to: format)

    let bufferCapacity = AVAudioFrameCount(format.sampleRate) * 10
    let inputBuffer = AVAudioPCMBuffer(pcmFormat: inputFile.processingFormat, frameCapacity: bufferCapacity)
    let outputBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bufferCapacity)

    while let buffer = inputBuffer {
        do {
            try inputFile.read(into: buffer)
        } catch {
            completion(false, error, nil, nil)
            return
        }

        let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }

        converter?.convert(to: outputBuffer!, error: nil, withInputFrom: inputBlock)

        do {
            try outputFile.write(from: outputBuffer!)
        } catch {
            completion(false, error, nil, nil)
            return
        }
    }

    // Get file size and confirm successful conversion
    let fileManager = FileManager.default
    if let fileSize = try? fileManager.attributesOfItem(atPath: outputURL.path)[.size] as? UInt64 {
        completion(true, nil, outputURL, fileSize)
    } else {
        completion(true, nil, outputURL, nil)
    }
}
func createAudioMix(for asset: AVAsset, with audioSettings: [String: Any]) -> AVAudioMix {
    let audioMix = AVMutableAudioMix()
    let audioTracks = asset.tracks(withMediaType: .audio)
    
    if let audioTrack = audioTracks.first {
        let audioInputParams = AVMutableAudioMixInputParameters(track: audioTrack)
        audioInputParams.audioTimePitchAlgorithm = .varispeed
        audioMix.inputParameters = [audioInputParams]
    }
    
    return audioMix
}
