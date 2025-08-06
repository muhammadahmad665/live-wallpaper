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
        guard let asset = asset else { return false }
        let duration = endTime - startTime
        let finalDuration = duration / speedMultiplier
        return duration > 0 && finalDuration <= 5.0
    }
    
    /// Gets a status message based on current state
    private var statusMessage: String {
        if isProcessing {
            return "Creating your Live Wallpaper..."
        } else if !isSelectionValid {
            let duration = endTime - startTime
            let finalDuration = duration / speedMultiplier
            return "Adjust your selection: Duration \(String(format: "%.1f", duration))s → \(String(format: "%.1f", finalDuration))s (max 5.0s)"
        } else {
            return "Ready to create your Live Wallpaper!"
        }
    }
    
    /// Gets the appropriate status color
    private var statusColor: Color {
        if isProcessing {
            return .orange
        } else if !isSelectionValid {
            return .red
        } else {
            return .green
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Status indicator
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                    .opacity(isProcessing ? 0.8 : 1.0)
                    .scaleEffect(isProcessing ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isProcessing)
                
                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundColor(statusColor)
                    .fontWeight(.medium)
                
                Spacer()
                
                if isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal)
            
            // Action buttons
            VStack(spacing: 12) {
                // Preview button
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onPreview()
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                        Text("Preview at \(speedMultiplier, specifier: "%.1f")× Speed")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(asset == nil || isProcessing)
                .opacity((asset == nil || isProcessing) ? 0.6 : 1.0)
                
                // Create wallpaper button
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                    impactFeedback.impactOccurred()
                    onCreateWallpaper()
                }) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "wand.and.stars")
                                .font(.title2)
                        }
                        Text(isProcessing ? "Creating..." : "Create Live Wallpaper")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(!canProcess || isProcessing || !isSelectionValid)
                .opacity((!canProcess || isProcessing || !isSelectionValid) ? 0.6 : 1.0)
                
                // Debug info for troubleshooting
                if !canProcess || !isSelectionValid {
                    Text("Debug: canProcess=\(canProcess), isSelectionValid=\(isSelectionValid), duration=\(String(format: "%.1f", endTime - startTime))")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
            }
            .padding(.horizontal)
            
            // Tips for better results
            if !isProcessing {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Pro Tips", systemImage: "lightbulb.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        tipItem("Choose moments with smooth motion for best results")
                        tipItem("Higher speeds create more dynamic wallpapers")
                        tipItem("Keep final duration under 5 seconds for Live Photos")
                        tipItem("Preview before creating to ensure quality")
                    }
                }
                .padding()
                .background(.orange.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
        .alert("Processing Status", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    /// Creates a tip item with bullet point styling
    private func tipItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.orange.opacity(0.6))
                .frame(width: 4, height: 4)
                .padding(.top, 6)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
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
