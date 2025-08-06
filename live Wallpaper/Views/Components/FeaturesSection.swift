//
//  FeaturesSection.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

struct FeaturesSection: View {
    var body: some View {
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
    }
}