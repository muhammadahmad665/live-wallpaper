//
//  VideoPlayerComponent.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import AVKit

/// Component for displaying and controlling video playback
struct VideoPlayerComponent: View {
    let videoURL: URL
    let player: AVPlayer?
    let showAspectRatioWarning: Bool
    let aspectRatio: CGFloat
    let videoResolution: CGSize
    
    let onPlaySelection: () -> Void
    let onSeekToStart: () -> Void
    let onShowAspectRatioWarning: () -> Void
    let onDismissAspectRatioWarning: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Video player with custom styling
            ZStack {
                VideoPlayer(player: player ?? AVPlayer(url: videoURL))
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.quaternary, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                // Play button overlay when paused
                if player?.timeControlStatus != .playing {
                    Button(action: onPlaySelection) {
                        ZStack {
                            Circle()
                                .fill(.black.opacity(0.7))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Aspect ratio warning
            if showAspectRatioWarning {
                AspectRatioWarningView(
                    currentRatio: aspectRatio,
                    resolution: videoResolution,
                    onDismiss: onDismissAspectRatioWarning
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            // Quick action buttons
            HStack(spacing: 12) {
                Button(action: onPlaySelection) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.circle.fill")
                        Text("Preview")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.blue.opacity(0.1))
                    .clipShape(Capsule())
                }
                
                Button(action: onSeekToStart) {
                    HStack(spacing: 6) {
                        Image(systemName: "gobackward")
                        Text("Reset")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.gray.opacity(0.1))
                    .clipShape(Capsule())
                }
                
                Button(action: onShowAspectRatioWarning) {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                        Text("Info")
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.orange.opacity(0.1))
                    .clipShape(Capsule())
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Aspect Ratio Warning Component
struct AspectRatioWarningView: View {
    let currentRatio: CGFloat
    let resolution: CGSize
    let onDismiss: () -> Void
    
    private var isPortrait: Bool {
        resolution.height > resolution.width
    }
    
    private var aspectRatioStatus: (message: String, color: Color, icon: String) {
        let idealRatio: CGFloat = 9.0/16.0 // Portrait ratio
        let currentDisplayRatio = isPortrait ? resolution.width / resolution.height : resolution.height / resolution.width
        
        if abs(currentDisplayRatio - idealRatio) < 0.1 {
            return ("Perfect for Live Wallpapers!", Color.green, "checkmark.circle.fill")
        } else if abs(currentDisplayRatio - idealRatio) < 0.2 {
            return ("Good aspect ratio", Color.orange, "exclamationmark.triangle.fill")
        } else {
            return ("May not fill screen perfectly", Color.red, "xmark.circle.fill")
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: aspectRatioStatus.icon)
                    .foregroundColor(aspectRatioStatus.color)
                    .font(.title2)
                
                Text("Video Analysis")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title2)
                }
            }
            
            // Status message
            Text(aspectRatioStatus.message)
                .font(.subheadline)
                .foregroundColor(aspectRatioStatus.color)
                .fontWeight(.medium)
            
            // Video specs
            VStack(spacing: 12) {
                HStack {
                    Text("Resolution:")
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(Int(resolution.width)) × \(Int(resolution.height))")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Orientation:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(isPortrait ? "Portrait" : "Landscape")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Aspect Ratio:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(String(format: "%.2f:1", currentRatio))
                        .foregroundColor(.secondary)
                }
            }
            .font(.subheadline)
            
            // Recommendations
            VStack(alignment: .leading, spacing: 8) {
                Text("💡 Tips for best results:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Portrait videos (9:16) work best")
                    Text("• Square videos (1:1) are also good")
                    Text("• Landscape videos may have black bars")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

#Preview {
    VideoPlayerComponent(
        videoURL: URL(string: "https://example.com/video.mp4")!,
        player: nil,
        showAspectRatioWarning: false,
        aspectRatio: 16/9,
        videoResolution: CGSize(width: 1920, height: 1080),
        onPlaySelection: {},
        onSeekToStart: {},
        onShowAspectRatioWarning: {},
        onDismissAspectRatioWarning: {}
    )
}
