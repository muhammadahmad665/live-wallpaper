//
//  AppIconView.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

/// A custom app icon view that displays an animated app icon
struct AppIconView: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [
                            .blue.opacity(0.8),
                            .purple.opacity(0.6),
                            .blue.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 88, height: 88)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Icon layers
            ZStack {
                // Background video symbol
                Image(systemName: "video.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .offset(x: -2, y: 2)
                
                // Foreground phone symbol
                Image(systemName: "iphone")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotationAngle))
                
                // Sparkle effect
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.yellow)
                    .offset(x: 15, y: -15)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.7)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

#Preview {
    AppIconView()
}
