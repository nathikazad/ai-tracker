//
//  AudioRecorder.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
import AVFoundation
import SwiftUI

/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
actor AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    var audioRecorder: AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var isRecording: Bool = false;
    override init() {
        super.init()
        Task {
            do {
                guard AVAudioSession.sharedInstance().recordPermission == AVAudioSession.RecordPermission.granted else {
                    throw AVError(AVError.applicationIsNotAuthorized)
                }
                
            } catch {
//                transcribe(error)
            }
        }
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                    } else {
//                        throw AVError(AVError.applicationIsNotAuthorized)
                    }
                }
            }
        } catch {
            // failed to record
        }
    }
    
    @MainActor func startRecording() {
        Task {
            await record()
        }
    }
    
    @MainActor func stopRecording() async -> URL {
        await Task {
            await stop()
        }
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
            
        } catch {
            stop()
        }
        
//        let settings = [
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 12000,
//            AVNumberOfChannelsKey: 1,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//
//        do {
//            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
//            audioRecorder.delegate = self
//            audioRecorder.record()
//
//            isRecording = true;
//        } catch {
//            stop()
//        }
    }
    
    private func getFileName() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        return paths[0].appendingPathComponent("recording.m4a")
    }
    
    private func stop() {
        audioRecorder?.stop()
        print("stopped")
        audioRecorder = nil
        isRecording = false;
//        playRecording()
    }
    
    func playRecording() {
        do {
//            let audioPlayer = try AVAudioPlayer(contentsOf: getFileName())
//            audioPlayer.prepareToPlay()
            preparePlayer()
            audioPlayer.play()
        } catch {
            print("Failed to play the recording: \(error)")
        }
    }
    
    func preparePlayer() {
        var error: NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileName() as URL)
            AudioUploader().uploadAudioFile(at: getFileName(), to: "http://100.87.137.10:3000/upload")
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
