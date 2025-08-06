//
//  VideoSelectionView.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import PhotosUI

/// View for selecting a video from the user's photo library
/// Displays introductory information and a button to launch the PhotosPicker
struct VideoSelectionView: View {
    /// Callback function to execute when a video is selected
    let onSelectVideo: (PhotosPickerItem) -> Void
    /// Currently selected item from the picker (if any)
    @State private var selectedItem: PhotosPickerItem?
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Hero section with animated icon
                VStack(spacing: 20) {
                    ZStack {
                        // Background gradient circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 160, height: 160)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                        
                        // Main icon with gradient
                        Image(systemName: "video.badge.waveform")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .symbolEffect(.bounce, value: isAnimating)
                    }
                    
                    // App title with style
                    VStack(spacing: 8) {
                        Text("Live Wallpaper Creator")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Transform your videos into stunning Live Wallpapers")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .onAppear {
                    isAnimating = true
                }
                
                // Features section
                VStack(spacing: 16) {
                    FeatureRow(
                        icon: "scissors",
                        title: "Smart Trimming",
                        description: "Easily trim your video to the perfect 5-second duration"
                    )
                    
                    FeatureRow(
                        icon: "speedometer",
                        title: "Speed Control",
                        description: "Adjust playback speed to pack more motion into your Live Wallpaper"
                    )
                    
                    FeatureRow(
                        icon: "viewfinder",
                        title: "Aspect Ratio Analysis",
                        description: "Get warnings and tips for optimal aspect ratios"
                    )
                    
                    FeatureRow(
                        icon: "wand.and.rays",
                        title: "Auto Optimization",
                        description: "Automatically optimized for Live Wallpaper format"
                    )
                }
                .padding(.horizontal)
                
                // Call to action
                VStack(spacing: 16) {
                    // PhotosPicker button with enhanced styling
                    PhotosPicker(selection: $selectedItem,
                                matching: .videos,
                                photoLibrary: .shared()) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Choose Your Video")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .scaleEffect(isAnimating ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text("Select a video from your photo library to get started")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .onChange(of: selectedItem) { _, newItem in
            if let newItem = newItem {
                onSelectVideo(newItem)
            }
        }
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon container
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
