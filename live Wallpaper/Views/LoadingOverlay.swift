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
    
    var body: some View {
        ZStack {
            // Semi-transparent background to dim the content behind
            Color.black.opacity(0.6)
            
            // Content container with progress indicator and messages
            VStack(spacing: 15) {
                // Spinning progress indicator
                ProgressView()
                    .scaleEffect(1.8)
                    .tint(.white)
                
                // Primary message explaining the current operation
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Secondary message indicating operation may take time
                Text("This may take a moment...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.7))
            )
        }
        .ignoresSafeArea()
    }
}
