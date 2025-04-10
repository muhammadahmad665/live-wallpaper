//
//  VideoEditingView.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import AVKit

/// View for trimming and previewing a selected video
/// Allows users to select a specific portion of a video to use as a Live Wallpaper
struct VideoEditingView: View {
    /// URL of the video to be edited
    let videoURL: URL
    /// Binding to the start time for trimming (in seconds)
    @Binding var startTime: Double
    /// Binding to the end time for trimming (in seconds)
    @Binding var endTime: Double
    /// Total duration of the video in seconds
    let videoDuration: Double
    /// Flag indicating if processing is in progress
    let isProcessing: Bool
    /// URL of the trimmed video if available
    let trimmedVideoURL: URL?
    /// Action to execute when the "Process Video" button is tapped
    let onProcessVideo: () -> Void
    /// Action to execute when the "Save as Wallpaper" button is tapped
    let onSaveVideo: () -> Void
    
    /// AVPlayer instance for video playback
    @State private var player: AVPlayer?
    /// Token for time observation to track playback progress
    @State private var timeObserverToken: Any?
    
    var body: some View {
        VStack(spacing: 16) {
            // Use the stored player instead of creating a new one each time
            VideoPlayer(player: player ?? AVPlayer(url: videoURL))
                .frame(height: 300)
                .cornerRadius(12)
                .onAppear {
                    setupPlayer()
                }
            
            VStack(spacing: 8) {
                Text("Trim Video (Max 5 seconds)")
                    .font(.headline)
                
                HStack {
                    Text(TimeFormatter.formatTime(startTime))
                    Spacer()
                    Text(TimeFormatter.formatTime(endTime))
                }
                
                RangeSlider(
                    lowerValue: $startTime,
                    upperValue: $endTime,
                    minimumValue: 0,
                    maximumValue: min(videoDuration, 15),
                    step: 0.1,
                    maxRange: 5.0
                )
                .frame(height: 40)
                .onChange(of: startTime) { _, _ in
                    seekToStartTime()
                }
                .onChange(of: endTime) { _, _ in
                    // Optionally, you could also update end time in some way
                }
                
                Text("Duration: \(TimeFormatter.formatTime(endTime - startTime))")
                    .font(.subheadline)
                    .foregroundColor(.primary) // Always primary color since we enforce 5sec max
                
                Button("Play Selection") {
                    playSelection()
                }
                .padding(.vertical, 8)
            }
            .padding(.vertical)
            
            Button(action: onProcessVideo) {
                HStack {
                    Image(systemName: "scissors")
                    Text("Process Video")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isProcessing)
            .padding(.horizontal)
            
            if let _ = trimmedVideoURL {
                Button(action: onSaveVideo) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save as Wallpaper")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
    }
    
    /// Sets up the AVPlayer with the current video URL
    private func setupPlayer() {
        let player = AVPlayer(url: videoURL)
        self.player = player
        seekToStartTime()
    }
    
    /// Seeks the player to the current start time position
    private func seekToStartTime() {
        let time = CMTime(seconds: startTime, preferredTimescale: 600)
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    /// Plays the selected portion of the video from start time to end time
    /// Automatically stops playback when reaching the end time
    private func playSelection() {
        guard let player = player else { return }
        
        // Remove any existing observer first
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        
        // Seek to start time
        let startCMTime = CMTime(seconds: startTime, preferredTimescale: 600)
        player.seek(to: startCMTime, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
            if finished {
                // Start playback
                player.play()
                
                // Set up a new observer
                let observer = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) {  time in
                    let currentSeconds = time.seconds
                    if currentSeconds >= self.endTime {
                        player.pause()
                        // Don't remove the observer here - we'll handle that separately
                    }
                }
                
                // Store the observer token for later removal
                self.timeObserverToken = observer
            }
        }
    }
    
    /// Cleans up resources when the view disappears
    /// Removes time observers to prevent memory leaks
    private func cleanup() {
        if let player = player, let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
}

// Add a function to clean up when the view disappears
extension VideoEditingView {
    /// Creates a coordinator to handle view lifecycle events
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    /// Coordinator class that handles cleanup when the view is deallocated
    class Coordinator {
        let parent: VideoEditingView
        
        init(parent: VideoEditingView) {
            self.parent = parent
        }
        
        deinit {
            parent.cleanup()
        }
    }
}
