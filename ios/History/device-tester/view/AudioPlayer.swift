//
//  AudioPlayer.swift
//  device-tester
//
//  Created by Nathik Azad on 1/1/25.
//

import SwiftUI
import AVKit
struct AudioPlayerView: View {
    let url: URL
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var gain: Float = 10.0  // Add gain state
    
    var body: some View {
        VStack(spacing: 16) {
            Text(url.lastPathComponent)
                .font(.headline)
            
            // Time and Progress
            HStack {
                Text(formatTime(currentTime))
                Spacer()
                if let duration = player?.duration {
                    Text(formatTime(duration))
                }
            }
            .font(.caption)
            .monospacedDigit()
            
            // Progress Bar
            if let player = player {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: max(0, min(geometry.size.width * CGFloat(currentTime / player.duration), geometry.size.width)), height: 4)
                    }
                }
                .frame(height: 4)
            }
            
            // Playback Controls
            HStack(spacing: 20) {
                Button(action: togglePlayPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .onAppear {
            setupAudioPlayer()
        }
        .onDisappear {
            cleanup()
        }
    }
    
    private func setupAudioPlayer() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.volume = gain  // Set initial gain
            
            // Setup timer for progress updates
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if let player = player, player.isPlaying {
                    currentTime = player.currentTime
                }
            }
        } catch {
            print("Error setting up audio player: \(error)")
        }
    }
    
    private func updateGain() {
        player?.volume = gain
    }
    
    private func cleanup() {
        timer?.invalidate()
        timer = nil
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    private func togglePlayPause() {
        guard let player = player else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
