//
//  transcriber.swift
//  device-tester
//
//  Created by Nathik Azad on 12/12/24.
//

import Foundation
import AVFoundation

import Speech

class AudioTranscriber: NSObject, SFSpeechRecognizerDelegate {
    private var transcriptionCallback: ((String) -> Void)?
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var previous: String = ""
    override init() {
        super.init()
        speechRecognizer?.delegate = self
        requestAuthorization()
    }
    
    private func requestAuthorization() {
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
    
    func setTranscriptionCallback(_ callback: @escaping (String) -> Void) {
        transcriptionCallback = callback
    }
    
    func processAudio(_ audioData: Data) {
        
        // Decode ADPCM data to PCM
        let decodedData = ADPCM.decodeBlock(audioData)
        
        // Create an audio buffer from the decoded data
        let format = AVAudioFormat(commonFormat: .pcmFormatInt16,
                                 sampleRate: 4000,
                                 channels: 1,
                                 interleaved: true)!
        
        let frameCount = AVAudioFrameCount(decodedData.count)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            print("Failed to create audio buffer")
            return
        }
        
        buffer.frameLength = frameCount
        
        // Copy samples to buffer
        let ptr = buffer.int16ChannelData?[0]
        decodedData.withUnsafeBytes { (samples: UnsafeRawBufferPointer) in
            guard let source = samples.bindMemory(to: Int16.self).baseAddress else { return }
            ptr?.assign(from: source, count: decodedData.count)
        }
        
        transcribeAudio(buffer) { [weak self] result in
            if let transcript = result {
                print("\(transcript)")
                self?.transcriptionCallback?(transcript)
            }
        }
    }
    
    private func transcribeAudio(_ buffer: AVAudioPCMBuffer, completion: @escaping (String?) -> Void) {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("Speech recognizer is not available")
            completion(nil)
            return
        }
        
        // Cancel any existing recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.requiresOnDeviceRecognition = false
        recognitionRequest.shouldReportPartialResults = false
        self.recognitionRequest = recognitionRequest
        
        // Set up recognition handler
        let handler: (SFSpeechRecognitionResult?, Error?) -> Void = { [weak self] result, error in
            defer {
                self?.recognitionTask = nil
                self?.recognitionRequest = nil
            }
            
            if let error = error as NSError? {
                if error.domain == "kAFAssistantErrorDomain" && error.code == 1110 {
                    completion("")  // No speech detected
                } else {
                    print("Recognition error: \(error)")
                    completion(nil)
                }
                return
            }
            
            if let result = result, result.isFinal {
                completion(self?.previous ?? ""+" "+result.bestTranscription.formattedString.lowercased())
                self?.previous = result.bestTranscription.formattedString.lowercased()
            }
        }
        
        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: handler)
        
        // Add timeout
        DispatchQueue.global().asyncAfter(deadline: .now() + 10.0) { [weak self] in
            if self?.recognitionTask != nil {
                print("Recognition timed out")
                self?.recognitionTask?.cancel()
                self?.recognitionTask = nil
                completion(nil)
            }
        }
        
        // Process audio buffer
        recognitionRequest.append(buffer)
        recognitionRequest.endAudio()
    }
}
class ADPCM {
    // ADPCM tables
    private static let stepTable: [Int32] = [7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
                                    50, 55, 60, 66, 73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230,
                                    253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963,
                                    1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327,
                                    3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442,
                                    11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794,
                                    32767]
    private static let indexTable: [Int8] = [-1, -1, -1, -1, 2, 4, 6, 8]
    static func decodeBlock(_ inbuf: Data) -> [Int16] {
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
}
