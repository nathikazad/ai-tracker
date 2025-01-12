//
//  transcriber.swift
//  device-tester
//
//  Created by Nathik Azad on 12/12/24.
//

import Foundation
import AVFoundation

import Speech
//import OpenAI

class AudioTranscriber: NSObject, SFSpeechRecognizerDelegate {
    private var audioData = Data()
    private var expectedPackets: UInt8 = 0
    private var receivedPackets: UInt8 = 0
    private var transcriptionCallback: ((String) -> Void)?
    
    
    // Speech recognition properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var isProcessing = false
    private let processingQueue = DispatchQueue(label: "com.audioTranscriber.processing")
        
    
    override init() {
        super.init()
        speechRecognizer?.delegate = self
        
        // Request speech recognition authorization
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("Speech recognition authorized")
            case .denied:
                print("Speech recognition authorization denied")
            case .restricted:
                print("Speech recognition restricted on this device")
            case .notDetermined:
                print("Speech recognition not yet authorized")
            @unknown default:
                print("Unknown authorization status")
            }
        }
    }
    
    // ADPCM tables
    private let stepTable: [Int32] = [7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
                                    50, 55, 60, 66, 73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230,
                                    253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963,
                                    1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327,
                                    3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442,
                                    11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794,
                                    32767]
    private let indexTable: [Int8] = [-1, -1, -1, -1, 2, 4, 6, 8]
    
    func setTranscriptionCallback(_ callback: @escaping (String) -> Void) {
        transcriptionCallback = callback
    }
    
    func handleAudioData(_ data: Data) {
        if data.prefix(5) == Data("START".utf8) {
//            print("Started receiving audio")
            audioData.removeAll()
            expectedPackets = data.count >= 8 ? data[7] : 0
            receivedPackets = 0
            
        } else if data.prefix(2) == Data([0xFF, 0xFF]) {
            audioData.append(data.dropFirst(4))
            receivedPackets += 1
            
        } else if data.prefix(3) == Data("END".utf8) {
//            print("Stopped receiving audio")
            processAudio()
        }
    }
    
    private func processAudio() {
        guard !isProcessing else {
            print("Already processing audio, skipping")
            return
        }
        
        isProcessing = true
//        print("Processing audio")
//        print("Raw audio data size: \(audioData.count) bytes")
        
        let decodedData = adpcmDecodeBlock(audioData)
//        print("Decoded data size: \(decodedData.count) samples")
        
        // Create temporary WAV file
        let tempDir = FileManager.default.temporaryDirectory
        let wavURL = tempDir.appendingPathComponent(UUID().uuidString + ".wav")
//        print("WAV file path: \(wavURL.path)")
        
        do {
            let dataSize = UInt32(decodedData.count * MemoryLayout<Int16>.size)
            let wavHeader = generateWavHeader(sampleRate: 4000,
                                            bitsPerSample: 16,
                                            channels: 1,
                                            dataSize: dataSize)
            
//            print("WAV header size: \(wavHeader.count) bytes")
//            print("Data size in header: \(dataSize) bytes")
            
            var fileData = Data()
            fileData.append(wavHeader)
            
            // Convert samples to bytes
            decodedData.withUnsafeBytes { ptr in
                fileData.append(Data(ptr))
            }
            
//            print("Total WAV file size: \(fileData.count) bytes")
//            print("WAV header bytes: \(Array(fileData.prefix(44)).map { String(format: "%02X", $0) }.joined(separator: " "))")
            
            // Write file
            try fileData.write(to: wavURL)
            
            // Verify file contents
            let writtenData = try Data(contentsOf: wavURL)
//            print("Written file size matches: \(writtenData.count == fileData.count)")
//            print("Written header matches: \(writtenData.prefix(44).elementsEqual(wavHeader))")
            
            // Try to read as audio file
            let audioFile = try AVAudioFile(forReading: wavURL)
//            print("Successfully created audio file")
//            print("Format: \(audioFile.processingFormat)")
//            print("Frame length: \(audioFile.length)")
            
            transcribeWav(url: wavURL) { [weak self] result in
                if let transcript = result {
                    print("Received text: \(transcript)")
                    self?.transcriptionCallback?(transcript)
                    
                    do {
                        try FileManager.default.removeItem(at: wavURL)
//                        print("Successfully deleted WAV file")
                    } catch {
                        print("Error deleting WAV file: \(error)")
                    }
                }
                try? FileManager.default.removeItem(at: wavURL)
                self?.isProcessing = false
            }
            
        } catch {
            print("Error processing audio: \(error)")
            print("Error details: \(error.localizedDescription)")
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 15.0) { [weak self] in
            self?.isProcessing = false
        }
    }
    
    private func adpcmDecodeBlock(_ inbuf: Data) -> [Int16] {
//        print("Starting ADPCM decode with \(inbuf.count) bytes")
        if inbuf.count < 4 {
            print("Input buffer too small")
            return []
        }
        
        // Print first few bytes of input
//        print("First 4 bytes: \(Array(inbuf.prefix(4)).map { String(format: "%02X", $0) }.joined(separator: " "))")
        
        var pcmdata: Int32 = 0
        var index: Int8 = 0
        var outbuf: [Int16] = []
        
        guard inbuf.count >= 4 else { return [] }
        
        // Initialize first sample
        pcmdata = Int32(Int16(inbuf[0]) | (Int16(inbuf[1]) << 8))
        index = Int8(inbuf[2])
        
        guard index >= 0 && index <= 88 && inbuf[3] == 0 else { return [] }
        outbuf.append(Int16(pcmdata))
        
        var currentByte = 4
        while currentByte < inbuf.count {
            let byte = inbuf[currentByte]
            
            // Process low nibble
            var step = stepTable[Int(index)]
            var delta: Int32 = step >> 3
            
            if byte & 1 != 0 { delta += step >> 2 }
            if byte & 2 != 0 { delta += step >> 1 }
            if byte & 4 != 0 { delta += step }
            
            if byte & 8 != 0 {
                pcmdata -= delta
            } else {
                pcmdata += delta
            }
            
            index += indexTable[Int(byte & 0x7)]
            index = max(0, min(index, 88))
            pcmdata = max(-32768, min(pcmdata, 32767))
            outbuf.append(Int16(pcmdata))
            
            // Process high nibble
            step = stepTable[Int(index)]
            delta = step >> 3
            
            if byte & 0x10 != 0 { delta += step >> 2 }
            if byte & 0x20 != 0 { delta += step >> 1 }
            if byte & 0x40 != 0 { delta += step }
            
            if byte & 0x80 != 0 {
                pcmdata -= delta
            } else {
                pcmdata += delta
            }
            
            index += indexTable[Int((byte >> 4) & 0x7)]
            index = max(0, min(index, 88))
            pcmdata = max(-32768, min(pcmdata, 32767))
            outbuf.append(Int16(pcmdata))
            
            currentByte += 1
        }
        
//        print("Decoded \(outbuf.count) samples")
        return outbuf
    }
    
    private func generateWavHeader(sampleRate: UInt32, bitsPerSample: UInt16,
                                 channels: UInt16, dataSize: UInt32) -> Data {
        var header = Data(count: 44)
        
        // RIFF chunk descriptor
        header.replaceSubrange(0..<4, with: "RIFF".data(using: .ascii)!)
        let fileSize = UInt32(44 - 8 + dataSize) // File size minus RIFF chunk header
        withUnsafeBytes(of: fileSize.littleEndian) { header.replaceSubrange(4..<8, with: $0) }
        header.replaceSubrange(8..<12, with: "WAVE".data(using: .ascii)!)
        
        // fmt sub-chunk
        header.replaceSubrange(12..<16, with: "fmt ".data(using: .ascii)!)
        let fmtChunkSize: UInt32 = 16
        withUnsafeBytes(of: fmtChunkSize.littleEndian) { header.replaceSubrange(16..<20, with: $0) }
        let audioFormat: UInt16 = 1 // PCM
        withUnsafeBytes(of: audioFormat.littleEndian) { header.replaceSubrange(20..<22, with: $0) }
        withUnsafeBytes(of: channels.littleEndian) { header.replaceSubrange(22..<24, with: $0) }
        withUnsafeBytes(of: sampleRate.littleEndian) { header.replaceSubrange(24..<28, with: $0) }
        
        let byteRate = sampleRate * UInt32(channels) * UInt32(bitsPerSample) / 8
        withUnsafeBytes(of: byteRate.littleEndian) { header.replaceSubrange(28..<32, with: $0) }
        
        let blockAlign = channels * bitsPerSample / 8
        withUnsafeBytes(of: blockAlign.littleEndian) { header.replaceSubrange(32..<34, with: $0) }
        withUnsafeBytes(of: bitsPerSample.littleEndian) { header.replaceSubrange(34..<36, with: $0) }
        
        // data sub-chunk
        header.replaceSubrange(36..<40, with: "data".data(using: .ascii)!)
        withUnsafeBytes(of: dataSize.littleEndian) { header.replaceSubrange(40..<44, with: $0) }
        
        return header
    }
    
//    private func transcribeWav(url: URL, completion: @escaping (String?) -> Void) {
//        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
//            print("OpenAI API key not found")
//            completion(nil)
//            return
//        }
        
//        let openAI = OpenAI(apiToken: apiKey)
//        
//        Task {
//            do {
//                let transcription = try await openAI.audioTranscriptions(
//                    file: url,
//                    model: .whisper_1,
//                    language: nil
//                )
//                DispatchQueue.main.async {
//                    completion(transcription.text)
//                }
//            } catch {
//                print("Transcription error: \(error)")
//                DispatchQueue.main.async {
//                    completion(nil)
//                }
//            }
//        }
//    }
    
    func transcribeWav(url: URL, completion: @escaping (String?) -> Void) {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("Speech recognizer is not available")
            completion(nil)
            return
        }
        
        // Cancel any existing recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Clean up previous request
        recognitionRequest = nil
        
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let audioFile = try AVAudioFile(forReading: url)
                let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                self.recognitionRequest = recognitionRequest
                
                recognitionRequest.shouldReportPartialResults = false
                
                let handler: (SFSpeechRecognitionResult?, Error?) -> Void = { result, error in
                    defer {
                        // Cleanup
                        self.recognitionTask = nil
                        self.recognitionRequest = nil
                    }
                    
                    if let error = error {
                        print("Recognition error: \(error)")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                        return
                    }
                    
                    if let result = result, result.isFinal {
                        DispatchQueue.main.async {
                            completion(result.bestTranscription.formattedString)
                        }
                    }
                }
                
                self.recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: handler)
                
                // Add timeout
                DispatchQueue.global().asyncAfter(deadline: .now() + 10.0) { [weak self] in
                    if self?.recognitionTask != nil {
                        print("Recognition timed out")
                        self?.recognitionTask?.cancel()
                        self?.recognitionTask = nil
                        completion(nil)
                    }
                }
                
                let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                            frameCapacity: AVAudioFrameCount(audioFile.length))!
                
                try audioFile.read(into: buffer)
                recognitionRequest.append(buffer)
                recognitionRequest.endAudio()
                
            } catch {
                print("Error setting up recognition: \(error)")
                completion(nil)
            }
        }
    }
}
