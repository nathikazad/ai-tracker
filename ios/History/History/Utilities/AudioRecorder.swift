//
//  AudioRecorder.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
import AVFoundation
import SwiftUI


protocol MicrophoneDelegate: AnyObject {
    func didStartRecording()
    func didStopRecording(response: String)
    func didStartProcessingRecording()
}

class Microphone {
    var audioRecorder: AudioRecorder?
    var recordingTimer: Timer?
    var isRecording = false
    var parse: Bool = true
    var parentEventId: Int? = nil
    
    weak var delegate: MicrophoneDelegate?
    
    func microphoneButtonClick(parse: Bool = true, parentEventId: Int? = nil) {
        DispatchQueue.main.async {
            self.delegate?.didStartProcessingRecording()
        }
        recordingTimer?.invalidate()
        recordingTimer = nil
        if !isRecording {
            self.parse = parse
            self.parentEventId = parentEventId
            Task.init {
                self.audioRecorder = AudioRecorder()
                await self.audioRecorder!.startRecording()
                isRecording = true
                DispatchQueue.main.async {
                    self.delegate?.didStartRecording()
                }
                print("Recording started")
            }
            recordingTimer = Timer.scheduledTimer(withTimeInterval: microphoneTimeout, repeats: false) { [weak self] _ in
                self?.microphoneButtonClick()
                print("Recording timed out")
            }
        } else {
            isRecording = false
            Task.init {
                let response = await self.stopRecording()
                DispatchQueue.main.async {
                    self.delegate?.didStopRecording(response: response)
                }
                self.audioRecorder = nil
                self.parse = true
                self.parentEventId = nil
                print("Recording stopped")
            }
        }
    }
    
    private func stopRecording() async -> String{
        guard let recorder = audioRecorder else { return "Audio recorder not initialized"}
        let fileUrl = await recorder.stopRecording()
        do {
            let data = try ServerCommunicator.uploadAudioFile(at: fileUrl, to: parseAudioEndpoint, token: Authentication.shared.hasuraJwt!, parse: parse, parentEventId: parentEventId)
           if let data = data {
               let decoder = JSONDecoder()
               do {
                   struct Response: Codable {
                       var status: String
                       var text: String
                   }
                   let jsonResponse = try decoder.decode(Response.self, from: data)
                   return jsonResponse.text
                   
               }
           } else {
               print("JSON decodong error")
               return "JSON decoding error"
           }
        } catch {
            print("Some uploading error")
            return "Some uploading error"
        }
    }
}


/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
actor AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    var audioRecorder: AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var isRecording: Bool = false;
    override init() {
        super.init()
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                    } else {
                        //                        throw AVError(AVError.applicationIsNotAuthorized)
                    }
                }
            }
        } catch {
            //            throw AVError(AVError.applicationIsNotAuthorized)
            // failed to record
        }
    }
    
    @MainActor func startRecording() async {
        await Task {
            do {
                try await recordingSession.setActive(true, options: [])
                await record()
            } catch {
                print("activate recording error")
            }
        }.value
        return;
    }
    
    @MainActor func stopRecording() async -> URL {
        await Task {
            await stop()
            do {
                try await recordingSession.setActive(false, options: [])
            } catch {
                print("deactivate recording error")
            }
        }.value
        
        return await getFileName()
    }
    
    private func record() {
        let audioFilename = getFileName()
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            isRecording = true;
            
        } catch {
            stop()
        }
        
    }
    
    private func getFileName() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0].appendingPathComponent("recording.m4a")
    }
    
    private func stop()  {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false;
        //        playRecording()
    }
    
    private func playRecording() {
        do {
            preparePlayer()
            audioPlayer.play()
        } catch {
            print("Failed to play the recording: \(error)")
        }
    }
    
    private func preparePlayer() {
        var error: NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileName() as URL)
            
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("AVAudioPlayer error: \(err.localizedDescription)")
        } else {
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 10.0
        }
    }
    
    private func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) async {
        if !flag {
            await stopRecording()
        }
    }
}
