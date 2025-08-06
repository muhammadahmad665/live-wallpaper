//
//  VideoProcessingActions.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import AVFoundation

/// Component for video processing actions and status
struct VideoProcessingActions: View {
    @Binding var speedMultiplier: Double
    @Binding var isProcessing: Bool
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    let asset: AVAsset?
    let startTime: Double
    let endTime: Double
    let canProcess: Bool
    let onCreateWallpaper: () -> Void
    let onPreview: () -> Void
    
    /// Computed property to check if the current selection is suitable for processing
    private var isSelectionValid: Bool {
        guard let asset = asset else { 
            print("🔍 isSelectionValid: false - no asset")
            return false 
        }
        let duration = endTime - startTime
        // Fixed: Higher speed = shorter final duration, so divide by speedMultiplier
        let finalDuration = duration / speedMultiplier
        let isValid = duration > 0 && finalDuration <= 5.0
        
        print("🔍 isSelectionValid check:")
        print("🔍   Duration: \(duration)s")
        print("🔍   Speed: \(speedMultiplier)x") 
        print("🔍   Final Duration: \(finalDuration)s")
        print("🔍   Valid: \(isValid) (duration > 0: \(duration > 0), finalDuration <= 5.0: \(finalDuration <= 5.0))")
        
        return isValid
    }
    
    /// Gets a simple status message
    private var statusMessage: String {
        let duration = endTime - startTime
        let finalDuration = duration / speedMultiplier
        
        if isProcessing {
            return "Creating Live Wallpaper..."
        } else if !isSelectionValid {
            if duration <= 0 {
                return "Select a video segment to continue"
            } else if finalDuration > 5.0 {
                return "Final duration (\(String(format: "%.1f", finalDuration))s) too long. Max 5 seconds."
            } else {
                return "Select a video segment to continue"
            }
        } else {
            return "Ready! Final duration: \(String(format: "%.1f", finalDuration))s"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Debug info to see what's happening
            VStack(spacing: 4) {
                Text("Debug Info:")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("Duration: \(String(format: "%.1f", endTime - startTime))s at \(String(format: "%.1f", speedMultiplier))x = \(String(format: "%.1f", (endTime - startTime) / speedMultiplier))s")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("Valid: \(isSelectionValid ? "✅" : "❌") | CanProcess: \(canProcess ? "✅" : "❌") | Processing: \(isProcessing ? "🔄" : "⏸️")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Simple status message
            Text(statusMessage)
                .font(.subheadline)
                .foregroundColor(isSelectionValid ? .green : .orange)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Main action button
            Button(action: {
                print("🎬 Create Live Wallpaper button tapped!")
                print("🎬 isSelectionValid: \(isSelectionValid)")
                print("🎬 canProcess: \(canProcess)")
                print("🎬 isProcessing: \(isProcessing)")
                print("🎬 Duration: \(endTime - startTime)s -> \((endTime - startTime) / speedMultiplier)s")
                
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                onCreateWallpaper()
            }) {
                HStack(spacing: 12) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "camera.fill")
                            .font(.title3)
                    }
                    
                    Text(isProcessing ? "Creating..." : "Create Live Wallpaper")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Group {
                        if isSelectionValid && !isProcessing {
                            Color.blue
                        } else {
                            Color.gray
                        }
                    }
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .disabled(!isSelectionValid || isProcessing)
            .animation(.easeInOut(duration: 0.2), value: isSelectionValid)
            .animation(.easeInOut(duration: 0.2), value: isProcessing)
            
            // Preview button (simplified)
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                onPreview()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.callout)
                    Text("Preview Selection")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(asset == nil || isProcessing)
            .opacity((asset == nil || isProcessing) ? 0.5 : 1.0)
        }
        .padding(.horizontal)
    }
}

#Preview {
    VideoProcessingActions(
        speedMultiplier: .constant(2.0),
        isProcessing: .constant(false),
        showAlert: .constant(false),
        alertMessage: .constant(""),
        asset: nil,
        startTime: 0,
        endTime: 3,
        canProcess: true,
        onCreateWallpaper: {},
        onPreview: {}
    )
    .padding()
}
