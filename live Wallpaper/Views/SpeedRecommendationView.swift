//
//  SpeedRecommendationView.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

/// A view that provides speed recommendations based on video content type
struct SpeedRecommendationView: View {
    @Binding var selectedSpeed: Double
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    HeaderSection(
                        iconName: "speedometer",
                        iconColors: [.purple, .blue],
                        title: "Speed Recommendations",
                        subtitle: "Choose the best speed for your video content"
                    )
                    
                    // Speed options with detailed descriptions
                    VStack(spacing: 16) {
                        SpeedOptionComponent(
                            speed: 1.0,
                            title: "Normal Speed",
                            description: "Keep original timing",
                            bestFor: "Subtle movements, nature scenes, slow transitions",
                            isSelected: selectedSpeed == 1.0
                        ) {
                            selectedSpeed = 1.0
                        }
                        
                        SpeedOptionComponent(
                            speed: 1.5,
                            title: "Smooth Motion",
                            description: "25% faster, natural feel",
                            bestFor: "Walking, gentle movements, flowing water",
                            isSelected: selectedSpeed == 1.5
                        ) {
                            selectedSpeed = 1.5
                        }
                        
                        SpeedOptionComponent(
                            speed: 2.0,
                            title: "Dynamic Action",
                            description: "2x speed, more engaging",
                            bestFor: "Busy scenes, traffic, clouds, crowds",
                            isSelected: selectedSpeed == 2.0
                        ) {
                            selectedSpeed = 2.0
                        }
                        
                        SpeedOptionComponent(
                            speed: 2.5,
                            title: "High Energy",
                            description: "Maximum motion density",
                            bestFor: "Fast action, sports, bustling city life",
                            isSelected: selectedSpeed == 2.5
                        ) {
                            selectedSpeed = 2.5
                        }
                    }
                    
                    BenefitsSection()
                }
                .padding()
            }
            .navigationTitle("Speed Guide")
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
    SpeedRecommendationView(selectedSpeed: .constant(2.0))
}
