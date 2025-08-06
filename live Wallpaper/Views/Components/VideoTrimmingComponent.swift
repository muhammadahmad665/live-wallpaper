//
//  VideoTrimmingComponent.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

/// Component for video trimming controls and time selection
struct VideoTrimmingComponent: View {
    @Binding var startTime: Double
    @Binding var endTime: Double
    @Binding var speedMultiplier: Double
    
    let videoDuration: Double
    let onStartTimeChange: () -> Void
    let onEndTimeChange: () -> Void
    let onSpeedMultiplierChange: () -> Void
    
    /// Computed property for the effective duration after speed adjustment
    private var effectiveDuration: Double {
        let rawDuration = endTime - startTime
        return rawDuration / speedMultiplier
    }
    
    /// Computed property to check if the effective duration is within Live Photo limits
    private var isEffectiveDurationValid: Bool {
        effectiveDuration <= 5.0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Section header
            HStack {
                Image(systemName: "scissors")
                    .foregroundColor(.blue)
                Text("Trim Video")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("Max 5 seconds")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.secondary.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            // Time display with better styling
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(TimeFormatter.formatTime(startTime))
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Duration badge with effective duration
                VStack(spacing: 4) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 2) {
                        Text(TimeFormatter.formatTime(endTime - startTime))
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        if speedMultiplier != 1.0 {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.right")
                                    .font(.caption2)
                                Text("\(TimeFormatter.formatTime(effectiveDuration))")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("(\(speedMultiplier, specifier: "%.1f")× speed)")
                                    .font(.caption2)
                                    .opacity(0.7)
                            }
                            .foregroundColor(isEffectiveDurationValid ? Color.green : Color.orange)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background((isEffectiveDurationValid ? Color.green : Color.orange).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("End")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(TimeFormatter.formatTime(endTime))
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            
            // Range slider with better spacing
            RangeSlider(
                lowerValue: $startTime,
                upperValue: $endTime,
                minimumValue: 0,
                maximumValue: min(videoDuration, 15),
                step: 0.1,
                maxRange: 5.0
            )
            .frame(height: 50)
            .onChange(of: startTime) { _, _ in
                onStartTimeChange()
            }
            .onChange(of: endTime) { _, _ in
                onEndTimeChange()
            }
            .onChange(of: speedMultiplier) { _, _ in
                onSpeedMultiplierChange()
            }
        }
        .padding()
        .background(.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VideoTrimmingComponent(
        startTime: .constant(0),
        endTime: .constant(5),
        speedMultiplier: .constant(1.0),
        videoDuration: 30,
        onStartTimeChange: {},
        onEndTimeChange: {},
        onSpeedMultiplierChange: {}
    )
    .padding()
}
