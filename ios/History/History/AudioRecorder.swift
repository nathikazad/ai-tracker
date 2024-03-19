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
actor AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    var audioRecorder: AVAudioRecorder!
    var recordingSession: AVAudioSession!
    var isRecording: Bool = false;
    override init() {
        Task {
            do {
                guard AVAudioSession.sharedInstance().recordPermission == AVAudioSession.RecordPermission.granted else {
                    throw AVError(AVError.applicationIsNotAuthorized)
                }
            } catch {
//                transcribe(error)
            }
        }
    }
    
    @MainActor func startRecording() {
        Task {
            await record()
        }
    }
    
    @MainActor func stopRecording() async -> String {
        await Task {
            await stop()
        }
        return await getFileName().path
    }
    
    fileprivate func printFileSize() {
        let audioFilename = getFileName()
        if FileManager.default.fileExists(atPath: audioFilename.path) {
            do {
                let resourceValues = try audioFilename.resourceValues(forKeys: [.fileSizeKey])
                let fileSize = resourceValues.fileSize!
                print("File size: \(fileSize) bytes")
            } catch {
                print("Failed to get file size: \(error)")
            }
        }
    }
    
    private func record() {
        let audioFilename = getFileName()
        printFileSize()
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
    
    private func stop() {
        audioRecorder?.stop()
        print("stopped")
        printFileSize()
        audioRecorder = nil
        isRecording = false;
    }
    
    private func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) async {
        if !flag {
            await stopRecording()
        }
    }
}
