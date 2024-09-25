import Cocoa
import Speech
import AVFoundation

class AudioTranscriber: NSObject, SFSpeechRecognizerDelegate {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var startTime: Date?
    
    override init() {
        super.init()
        speechRecognizer.delegate = self
    }

    func processAudioData(_ data: Data) {
        self.startTime = Date()
//        print("Transcribing audio, length \(data.count)")
        
        // End previous recognition task if any
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Create a new recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
            return
        }
        recognitionRequest.shouldReportPartialResults = true
        
        // Create a new recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
//                print("Transcription: \(result.bestTranscription.formattedString)")
                if result.isFinal {
                    if let startTime = self.startTime {
                        let duration = Date().timeIntervalSince(startTime) * 1000 // Convert to milliseconds
                        print("\nAudio data received successfully. Total time: \(String(format: "%.2f", duration)) ms")
                    }

                    print("Final transcription: \(result.bestTranscription.formattedString)")
                }
            } else if let error = error {
                print("Recognition error: \(error.localizedDescription)")
            }
        }
        
        // Process the audio data
        let audioFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 4000, channels: 1, interleaved: true)!
        let frameCount = UInt32(data.count) / 2 // 2 bytes per 16-bit sample
        
        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else {
            print("Failed to create PCM buffer")
            return
        }
        
        pcmBuffer.frameLength = frameCount
        
        data.withUnsafeBytes { (bufferPointer: UnsafeRawBufferPointer) in
            if let address = bufferPointer.baseAddress, let samples = pcmBuffer.int16ChannelData?[0] {
                samples.assign(from: address.assumingMemoryBound(to: Int16.self), count: Int(frameCount))
            }
        }
        
        recognitionRequest.append(pcmBuffer)
        recognitionRequest.endAudio()
    }

    func stopTranscribing() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }
}
