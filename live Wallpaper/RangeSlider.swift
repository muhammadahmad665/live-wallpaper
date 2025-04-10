//
//  RangeSlider.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

/// A custom SwiftUI range slider for selecting a time range within a video
/// Features smooth animations, drag gestures, and enforces a maximum range constraint
struct RangeSlider: View {
    /// Lower bound value binding (start time)
    @Binding var lowerValue: Double
    /// Upper bound value binding (end time)
    @Binding var upperValue: Double
    /// Minimum allowed value for the slider (usually 0)
    let minimumValue: Double
    /// Maximum allowed value for the slider (usually video duration)
    let maximumValue: Double
    /// Increment step size for rounding values
    let step: Double
    /// Maximum allowed range between lower and upper values (5 seconds for Live Photos)
    let maxRange: Double
    
    /// State tracking whether lower thumb is currently being dragged
    @State private var touchingLowerThumb = false
    /// State tracking whether upper thumb is currently being dragged
    @State private var touchingUpperThumb = false
    
    /// Size of the thumb controls
    var thumbSize: CGFloat = 28
    
    /// Initialize the range slider with all parameters
    /// - Parameters:
    ///   - lowerValue: Binding for the lower value (start time)
    ///   - upperValue: Binding for the upper value (end time)
    ///   - minimumValue: Minimum allowed value
    ///   - maximumValue: Maximum allowed value
    ///   - step: Step size for rounding values
    ///   - maxRange: Maximum allowed range between lower and upper values (defaults to 5.0)
    init(lowerValue: Binding<Double>, upperValue: Binding<Double>, minimumValue: Double, maximumValue: Double, step: Double, maxRange: Double = 5.0) {
        self._lowerValue = lowerValue
        self._upperValue = upperValue
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.step = step
        self.maxRange = maxRange
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                // Selected range indicator
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(
                        width: max(0, CGFloat((upperValue - lowerValue) / (maximumValue - minimumValue)) * geometry.size.width),
                        height: 4
                    )
                    .offset(x: max(0, CGFloat((lowerValue - minimumValue) / (maximumValue - minimumValue)) * geometry.size.width))
                    .cornerRadius(2)
                
                // Lower bound thumb control
                Circle()
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: CGFloat((lowerValue - minimumValue) / (maximumValue - minimumValue)) * geometry.size.width - thumbSize/2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                withAnimation(.spring()) {
                                    touchingLowerThumb = true
                                    updateLowerValue(for: value, in: geometry)
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.spring()) { touchingLowerThumb = false }
                            }
                    )
                
                // Upper bound thumb control
                Circle()
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: CGFloat((upperValue - minimumValue) / (maximumValue - minimumValue)) * geometry.size.width - thumbSize/2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                withAnimation(.spring()) {
                                    touchingUpperThumb = true
                                    updateUpperValue(for: value, in: geometry)
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.spring()) { touchingUpperThumb = false }
                            }
                    )
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: thumbSize)
    }
    
    /// Updates the lower value during a drag gesture while respecting constraints
    /// - Parameters:
    ///   - drag: The current drag gesture information
    ///   - geometry: The geometry proxy providing size information
    private func updateLowerValue(for drag: DragGesture.Value, in geometry: GeometryProxy) {
        let width = geometry.size.width
        
        // Calculate drag position and convert to value
        let dragPosition = drag.location.x
        let dragPercentage = dragPosition / width
        let newValue = ((maximumValue - minimumValue) * dragPercentage) + minimumValue
        
        // Round to nearest step value
        let steppedValue = round(newValue / step) * step
        
        // Enforce maximum range constraint by adjusting upper value if needed
        let potentialRange = upperValue - steppedValue
        if potentialRange > maxRange {
            // Calculate new upper value to maintain maxRange
            let newUpperValue = steppedValue + maxRange
            // Only update upper value if it's within bounds
            if newUpperValue <= maximumValue {
                upperValue = newUpperValue
            } else {
                // If we can't move upper thumb further, limit the lower thumb
                lowerValue = upperValue - maxRange
                return
            }
        }
        
        // Constrain lower value within allowed range and apply
        let constrainedValue = min(max(steppedValue, minimumValue), upperValue - step)
        lowerValue = constrainedValue
    }
    
    /// Updates the upper value during a drag gesture while respecting constraints
    /// - Parameters:
    ///   - drag: The current drag gesture information
    ///   - geometry: The geometry proxy providing size information
    private func updateUpperValue(for drag: DragGesture.Value, in geometry: GeometryProxy) {
        let width = geometry.size.width
        
        // Calculate drag position and convert to value
        let dragPosition = drag.location.x
        let dragPercentage = dragPosition / width
        let newValue = ((maximumValue - minimumValue) * dragPercentage) + minimumValue
        
        // Round to nearest step value
        let steppedValue = round(newValue / step) * step
        
        // Enforce maximum range constraint by adjusting lower value if needed
        let potentialRange = steppedValue - lowerValue
        if potentialRange > maxRange {
            // Calculate new lower value to maintain maxRange
            let newLowerValue = steppedValue - maxRange
            // Only update lower value if it's within bounds
            if newLowerValue >= minimumValue {
                lowerValue = newLowerValue
            } else {
                // If we can't move lower thumb further, limit the upper thumb
                upperValue = lowerValue + maxRange
                return
            }
        }
        
        // Constrain upper value within allowed range and apply
        let constrainedValue = min(max(steppedValue, lowerValue + step), maximumValue)
        upperValue = constrainedValue
    }
}

#Preview {
    RangeSlider(
        lowerValue: .constant(2),
        upperValue: .constant(7),
        minimumValue: 0,
        maximumValue: 10,
        step: 0.1,
        maxRange: 5.0
    )
    .frame(height: 50)
    .padding()
}
