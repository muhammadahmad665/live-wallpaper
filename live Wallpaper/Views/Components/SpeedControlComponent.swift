//
//  SpeedControlComponent.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

/// Component for speed control selection and feedback
struct SpeedControlComponent: View {
    @Binding var speedMultiplier: Double
    let startTime: Double
    let endTime: Double
    let onSpeedChange: (Double) -> Void
    
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
            HStack {
                Image(systemName: "speedometer")
                    .foregroundColor(.purple)
                Text("Playback Speed")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Final Duration:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(TimeFormatter.formatTime(effectiveDuration))")
                        .font(.caption)
                        .foregroundColor(isEffectiveDurationValid ? .green : .orange)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background((isEffectiveDurationValid ? Color.green : Color.orange).opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            
            // Speed selection buttons
            HStack(spacing: 12) {
                ForEach([1.0, 1.5, 2.0, 2.5], id: \.self) { speed in
                    Button(action: {
                        // Add haptic feedback for speed changes
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        withAnimation(.spring()) {
                            speedMultiplier = speed
                            onSpeedChange(speed)
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text("\(speed, specifier: "%.1f")×")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(speedDescription(for: speed))
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                            
                            // Show preview of what this speed would result in
                            Text("\(TimeFormatter.formatTime((endTime - startTime) / speed))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .opacity(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            speedMultiplier == speed 
                            ? Color.purple.opacity(0.2) 
                            : Color.gray.opacity(0.1)
                        )
                        .foregroundColor(
                            speedMultiplier == speed 
                            ? Color.purple 
                            : Color.secondary
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    speedMultiplier == speed 
                                    ? Color.purple 
                                    : Color.clear, 
                                    lineWidth: 2
                                )
                        )
                    }
                }
            }
            
            // Speed benefits explanation with real-time feedback
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Speed Conversion Preview:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        
                        Text("\(TimeFormatter.formatTime(endTime - startTime)) at \(speedMultiplier, specifier: "%.1f")× = \(TimeFormatter.formatTime(effectiveDuration)) final duration")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !isEffectiveDurationValid {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text("Final duration exceeds 5 seconds. Consider increasing speed or reducing clip length.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text("Perfect! Final duration is within Live Photo limits.")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    /// Returns a description for the given speed multiplier
    private func speedDescription(for speed: Double) -> String {
        switch speed {
        case 1.0: return "Normal\nSpeed"
        case 1.5: return "Smooth\nMotion"
        case 2.0: return "Dynamic\nAction"
        case 2.5: return "High\nEnergy"
        default: return "\(speed)×"
        }
    }
}

#Preview {
    SpeedControlComponent(
        speedMultiplier: .constant(1.0),
        startTime: 0,
        endTime: 5,
        onSpeedChange: { _ in }
    )
    .padding()
}
