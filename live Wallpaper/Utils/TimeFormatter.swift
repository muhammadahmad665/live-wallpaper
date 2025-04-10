//
//  TimeFormatter.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import Foundation

/// Utility struct for formatting time values for display
struct TimeFormatter {
    /// Formats a time value in seconds to a human-readable string (MM:SS.d)
    /// - Parameter time: Time value in seconds
    /// - Returns: Formatted time string in the format "minutes:seconds.tenths"
    static func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time - Double(Int(time))) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, milliseconds)
    }
}
