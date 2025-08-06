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
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "speedometer")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Speed Recommendations")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Choose the best speed for your video content")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Speed options with detailed descriptions
                    VStack(spacing: 16) {
                        SpeedOption(
                            speed: 1.0,
                            title: "Normal Speed",
                            description: "Keep original timing",
                            bestFor: "Subtle movements, nature scenes, slow transitions",
                            isSelected: selectedSpeed == 1.0
                        ) {
                            selectedSpeed = 1.0
                        }
                        
                        SpeedOption(
                            speed: 1.5,
                            title: "Smooth Motion",
                            description: "25% faster, natural feel",
                            bestFor: "Walking, gentle movements, flowing water",
                            isSelected: selectedSpeed == 1.5
                        ) {
                            selectedSpeed = 1.5
                        }
                        
                        SpeedOption(
                            speed: 2.0,
                            title: "Dynamic Action",
                            description: "2x speed, more engaging",
                            bestFor: "Busy scenes, traffic, clouds, crowds",
                            isSelected: selectedSpeed == 2.0
                        ) {
                            selectedSpeed = 2.0
                        }
                        
                        SpeedOption(
                            speed: 2.5,
                            title: "High Energy",
                            description: "Maximum motion density",
                            bestFor: "Fast action, sports, bustling city life",
                            isSelected: selectedSpeed == 2.5
                        ) {
                            selectedSpeed = 2.5
                        }
                    }
                    
                    // Benefits explanation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Why Speed Matters")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            BenefitRow(
                                icon: "film",
                                text: "More frames packed into 5 seconds"
                            )
                            
                            BenefitRow(
                                icon: "eye",
                                text: "More noticeable motion on lock screen"
                            )
                            
                            BenefitRow(
                                icon: "sparkles",
                                text: "Creates more engaging Live Wallpapers"
                            )
                            
                            BenefitRow(
                                icon: "battery.100",
                                text: "Still optimized for battery life"
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.gray.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
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

// MARK: - Speed Option Component
struct SpeedOption: View {
    let speed: Double
    let title: String
    let description: String
    let bestFor: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Speed indicator
                VStack(spacing: 4) {
                    Text("\(speed, specifier: "%.1f")×")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Circle()
                        .fill(isSelected ? .white.opacity(0.3) : .gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                .frame(width: 60)
                .padding(.vertical, 16)
                .background(
                    isSelected 
                    ? LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom)
                    : LinearGradient(colors: [.gray.opacity(0.1), .gray.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Best for: \(bestFor)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.purple)
                        .font(.title2)
                }
            }
            .padding()
            .background(isSelected ? .purple.opacity(0.1) : .gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .purple : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Benefit Row Component
struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .font(.subheadline)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SpeedRecommendationView(selectedSpeed: .constant(2.0))
}
