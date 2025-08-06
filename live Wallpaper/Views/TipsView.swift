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
                    HeaderSection(
                        iconName: "lightbulb.fill",
                        iconColors: [.yellow, .orange],
                        title: "Tips & Best Practices",
                        subtitle: "Get the most out of your Live Wallpapers"
                    )
                    
                    // Tips sections
                    VStack(spacing: 20) {
                        TipSectionComponent(
                            icon: "timer",
                            title: "Perfect Duration",
                            description: "Keep your videos between 3-5 seconds for the best Live Wallpaper experience. Shorter clips feel more natural and use less battery.",
                            color: Color.green
                        )
                        
                        TipSectionComponent(
                            icon: "viewfinder",
                            title: "Video Selection",
                            description: "Choose videos with interesting motion or subtle movements. Avoid shaky footage - smooth, steady clips work best.",
                            color: .blue
                        )
                        
                        TipSectionComponent(
                            icon: "battery.100",
                            title: "Battery Friendly",
                            description: "Live Wallpapers are optimized to minimize battery usage. The animation only plays when you 3D Touch or long press the lock screen.",
                            color: .orange
                        )
                        
                        TipSectionComponent(
                            icon: "rectangle.portrait",
                            title: "Portrait Mode",
                            description: "For best results, use videos shot in portrait orientation. The app will automatically optimize horizontal videos too.",
                            color: .purple
                        )
                        
                        TipSectionComponent(
                            icon: "gear",
                            title: "Setting Up",
                            description: "After saving, go to Settings > Wallpaper > Choose New Wallpaper > All Photos to find your Live Wallpaper and set it as your lock screen.",
                            color: .indigo
                        )
                        
                        TipSectionComponent(
                            icon: "speedometer",
                            title: "Speed Control",
                            description: "Use 1.5x - 2.5x speed to pack more motion into your 5-second Live Wallpaper. Higher speeds create more dynamic and engaging wallpapers.",
                            color: Color.purple
                        )
                        
                        TipSectionComponent(
                            icon: "viewfinder",
                            title: "Aspect Ratio",
                            description: "Portrait videos (9:16) work best for phone wallpapers. The app will analyze your video and warn you if the aspect ratio isn't optimal.",
                            color: Color.blue
                        )
                        
                        TipSectionComponent(
                            icon: "star.fill",
                            title: "Pro Tips",
                            description: "• Use 2x speed for action videos\n• Portrait orientation is optimal\n• Smooth motion works better than quick cuts\n• The key frame is from the middle of your selection",
                            color: Color.pink
                        )
                    }
                    
                    TipsCallToAction {
                        presentationMode.wrappedValue.dismiss()
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


#Preview {
    TipsView()
}
