//
//  LoadingOverlay.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

/// A fullscreen overlay with a progress indicator and message
/// Used to indicate that a long-running operation is in progress
struct LoadingOverlay: View {
    /// Message to display to the user about the current operation
    let message: String
    @State private var isAnimating = false
    @State private var progress: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Semi-transparent background with blur effect
            Color.black.opacity(0.4)
                .background(.ultraThinMaterial)
            
            // Content container with enhanced styling
            VStack(spacing: 20) {
                // Animated progress indicator
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 6)
                        .frame(width: 80, height: 80)
                    
                    // Animated progress circle
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                colors: [.blue, .purple, .blue],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isAnimating)
                    
                    // Center icon
                    Image(systemName: "wand.and.rays")
                        .font(.title2)
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                }
                
                VStack(spacing: 12) {
                    // Primary message with better typography
                    Text(message)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Progress steps
                    VStack(spacing: 8) {
                        ProgressStep(title: "Analyzing video", isActive: true)
                        ProgressStep(title: "Optimizing format", isActive: progress > 0.3)
                        ProgressStep(title: "Creating Live Photo", isActive: progress > 0.6)
                        ProgressStep(title: "Finalizing", isActive: progress > 0.9)
                    }
                    
                    // Secondary message
                    Text("This usually takes 10-30 seconds")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .italic()
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.8))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            )
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .ignoresSafeArea()
        .onAppear {
            isAnimating = true
            // Simulate progress animation
            withAnimation(.easeInOut(duration: 15)) {
                progress = 1.0
            }
        }
    }
}

// MARK: - Progress Step Component
struct ProgressStep: View {
    let title: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(isActive ? Color.green : Color.white.opacity(0.3))
                    .frame(width: 16, height: 16)
                
                if isActive {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(isActive ? .white : .white.opacity(0.6))
                .animation(.easeInOut(duration: 0.3), value: isActive)
            
            Spacer()
        }
        .scaleEffect(isActive ? 1.0 : 0.95)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isActive)
    }
}
