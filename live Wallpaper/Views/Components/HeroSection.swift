//
//  HeroSection.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

/**
 An animated hero section component for the video selection interface.
 
 This component creates an engaging, animated introduction to the Live Wallpaper
 Creator app. It features a pulsing background circle, animated app icon, and
 gradient text styling to create visual interest and guide user attention.
 
 ## Features
 
 - **Animated Background**: Pulsing gradient circle with continuous animation
 - **App Icon**: Large, prominent video waveform icon with bounce effects
 - **Gradient Typography**: Eye-catching text with gradient styling
 - **Automatic Animation**: Starts animating when the component appears
 
 ## Design Elements
 
 - Uses blue-to-purple gradient theme consistent with app branding
 - Implements smooth, continuous animations for engagement
 - Responsive typography that adapts to different screen sizes
 
 ## Usage
 
 ```swift
 HeroSection()
 ```
 
 - Note: Animation starts automatically when the view appears
 - Important: Uses `@State` for internal animation control
 */
struct HeroSection: View {
    
    // MARK: - State
    
    /**
     Controls the animation state of the hero section.
     
     When `true`, triggers continuous pulsing and bounce animations.
     Automatically set to `true` when the view appears.
     */
    @State private var isAnimating = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            // Animated icon container
            ZStack {
                // Background gradient circle with pulsing animation
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
                
                // Main app icon with gradient and bounce effect
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
            
            // Title and subtitle text
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
            // Start animations when the view appears
            isAnimating = true
        }
    }
}