//
//  TipsView.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

/// A view that displays helpful tips and best practices for creating Live Wallpapers
struct TipsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Tips & Best Practices")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Get the most out of your Live Wallpapers")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Tips sections
                    VStack(spacing: 20) {
                        TipSection(
                            icon: "timer",
                            title: "Perfect Duration",
                            description: "Keep your videos between 3-5 seconds for the best Live Wallpaper experience. Shorter clips feel more natural and use less battery.",
                            color: Color.green
                        )
                        
                        TipSection(
                            icon: "viewfinder",
                            title: "Video Selection",
                            description: "Choose videos with interesting motion or subtle movements. Avoid shaky footage - smooth, steady clips work best.",
                            color: .blue
                        )
                        
                        TipSection(
                            icon: "battery.100",
                            title: "Battery Friendly",
                            description: "Live Wallpapers are optimized to minimize battery usage. The animation only plays when you 3D Touch or long press the lock screen.",
                            color: .orange
                        )
                        
                        TipSection(
                            icon: "rectangle.portrait",
                            title: "Portrait Mode",
                            description: "For best results, use videos shot in portrait orientation. The app will automatically optimize horizontal videos too.",
                            color: .purple
                        )
                        
                        TipSection(
                            icon: "gear",
                            title: "Setting Up",
                            description: "After saving, go to Settings > Wallpaper > Choose New Wallpaper > All Photos to find your Live Wallpaper and set it as your lock screen.",
                            color: .indigo
                        )
                        
                        TipSection(
                            icon: "speedometer",
                            title: "Speed Control",
                            description: "Use 1.5x - 2.5x speed to pack more motion into your 5-second Live Wallpaper. Higher speeds create more dynamic and engaging wallpapers.",
                            color: Color.purple
                        )
                        
                        TipSection(
                            icon: "viewfinder",
                            title: "Aspect Ratio",
                            description: "Portrait videos (9:16) work best for phone wallpapers. The app will analyze your video and warn you if the aspect ratio isn't optimal.",
                            color: Color.blue
                        )
                        
                        TipSection(
                            icon: "star.fill",
                            title: "Pro Tips",
                            description: "• Use 2x speed for action videos\n• Portrait orientation is optimal\n• Smooth motion works better than quick cuts\n• The key frame is from the middle of your selection",
                            color: Color.pink
                        )
                    }
                    
                    // Call to action
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Ready to create amazing Live Wallpapers?")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        Button("Start Creating") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("Tips")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Tip Section Component
struct TipSection: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon container
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    TipsView()
}
