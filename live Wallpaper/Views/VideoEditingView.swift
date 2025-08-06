//
//  VideoEditingView.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import AVKit

/// View for trimming and previewing a selected video
/// Refactored to use modular components for better maintainability
struct VideoEditingView: View {
    /// URL of the video to be edited
    let videoURL: URL
    /// Binding to the start time for trimming (in seconds)
    @Binding var startTime: Double
    /// Binding to the end time for trimming (in seconds)
    @Binding var endTime: Double
    /// Binding to the speed multiplier for the video
    @Binding var speedMultiplier: Double
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
    /// Action to execute when the "Create Live Wallpaper" button is tapped
    let onCreateLiveWallpaper: () -> Void
    
    /// AVPlayer instance for video playback
    @State private var player: AVPlayer?
    /// Token for time observation to track playback progress
    @State private var timeObserverToken: Any?
    /// Video aspect ratio
    @State private var aspectRatio: CGFloat = 16/9
    /// Video resolution
    @State private var videoResolution: CGSize = .zero
    /// Optimal aspect ratio warning
    @State private var showAspectRatioWarning: Bool = false
    /// Alert state
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    /// Computed property to check if processing can be performed
    private var canProcess: Bool {
        let duration = endTime - startTime
        let finalDuration = duration / speedMultiplier
        return duration > 0 && finalDuration <= 5.0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Video Player Component
                VideoPlayerComponent(
                    videoURL: videoURL,
                    player: player,
                    showAspectRatioWarning: showAspectRatioWarning,
                    aspectRatio: aspectRatio,
                    videoResolution: videoResolution,
                    onPlaySelection: playSelection,
                    onSeekToStart: seekToStartTime,
                    onShowAspectRatioWarning: { 
                        withAnimation(.spring()) {
                            showAspectRatioWarning = true 
                        }
                    },
                    onDismissAspectRatioWarning: { 
                        withAnimation(.spring()) {
                            showAspectRatioWarning = false 
                        }
                    }
                )
                
                // Video Trimming Component
                VideoTrimmingComponent(
                    startTime: $startTime,
                    endTime: $endTime,
                    speedMultiplier: $speedMultiplier,
                    videoDuration: videoDuration,
                    onStartTimeChange: { seekToStartTime() },
                    onEndTimeChange: {
                        // Update preview if player is playing
                        if player?.timeControlStatus == .playing {
                            playSelection()
                        }
                    },
                    onSpeedMultiplierChange: {
                        // Update player rate in real-time and refresh preview when speed changes
                        updatePlayerRate()
                        if player?.timeControlStatus == .playing {
                            playSelection()
                        }
                    }
                )
                
                // Speed Control Component
                SpeedControlComponent(
                    speedMultiplier: $speedMultiplier,
                    startTime: startTime,
                    endTime: endTime,
                    onSpeedChange: { _ in
                        // Update player rate in real-time and refresh preview
                        updatePlayerRate()
                        if player?.timeControlStatus == .playing {
                            playSelection()
                        }
                    }
                )
                
                // Video Processing Actions Component
                VideoProcessingActions(
                    speedMultiplier: $speedMultiplier,
                    isProcessing: .constant(isProcessing),
                    showAlert: $showAlert,
                    alertMessage: $alertMessage,
                    asset: AVAsset(url: videoURL),
                    startTime: startTime,
                    endTime: endTime,
                    canProcess: canProcess,
                    onCreateWallpaper: onCreateLiveWallpaper,
                    onPreview: playSelection
                )
            }
            .padding()
        }
        .onAppear {
            setupPlayer()
            analyzeVideoProperties()
        }
    }
    
    // MARK: - Private Methods
    
    /// Sets up the AVPlayer with the current video URL
    private func setupPlayer() {
        let player = AVPlayer(url: videoURL)
        self.player = player
        seekToStartTime()
    }
    
    /// Analyzes video properties like aspect ratio and resolution
    private func analyzeVideoProperties() {
        let asset = AVAsset(url: videoURL)
        
        Task {
            do {
                guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else { return }
                let naturalSize = try await videoTrack.load(.naturalSize)
                let transform = try await videoTrack.load(.preferredTransform)
                
                // Calculate actual display size considering transform
                let size = naturalSize.applying(transform)
                let actualSize = CGSize(width: abs(size.width), height: abs(size.height))
                
                await MainActor.run {
                    self.videoResolution = actualSize
                    self.aspectRatio = actualSize.width / actualSize.height
                    
                    // Check if aspect ratio is not ideal for Live Wallpapers
                    let isPortrait = actualSize.height > actualSize.width
                    let idealRatio: CGFloat = 9.0/16.0 // Portrait ratio for phones
                    let currentRatio = isPortrait ? actualSize.width / actualSize.height : actualSize.height / actualSize.width
                    
                    // Show warning if not close to ideal mobile aspect ratio
                    if abs(currentRatio - idealRatio) > 0.2 {
                        withAnimation(.spring()) {
                            showAspectRatioWarning = true
                        }
                    }
                }
            } catch {
                print("Error analyzing video: \(error)")
            }
        }
    }
    
    /// Updates the player playback rate based on selected speed multiplier
    private func updatePlayerRate() {
        guard let player = player else { return }
        
        // Only update rate if the player is currently playing
        if player.timeControlStatus == .playing {
            player.rate = Float(speedMultiplier)
        }
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
                // Start playback with selected speed
                player.rate = Float(self.speedMultiplier)
                
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

// MARK: - View Lifecycle Extension
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
