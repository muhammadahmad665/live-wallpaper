//
//  LoadingOverlay.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

/// A simple fullscreen loading overlay
struct LoadingOverlay: View {
    let message: String
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.6)
            
            // Simple content container
            VStack(spacing: 24) {
                // Simple spinning indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                // Main message
                Text(message)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Simple secondary message
                Text("Please wait...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.8))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            )
            .shadow(color: .black.opacity(0.3), radius: 15)
        }
                .ignoresSafeArea()
        .onAppear {
            isAnimating = true
        }
    }
}
