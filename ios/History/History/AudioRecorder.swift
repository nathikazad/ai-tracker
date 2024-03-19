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
//            throw AVError(AVError.applicationIsNotAuthorized)
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
