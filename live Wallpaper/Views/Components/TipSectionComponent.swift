//
//  TipSectionComponent.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

/**
 A reusable component for displaying individual tips and advice sections.
 
 This component creates a consistent, visually appealing layout for presenting
 tips, best practices, and educational content throughout the app. It combines
 an icon, title, and description in a card-like format.
 
 ## Features
 
 - **Color-coded Icons**: Each tip has a themed icon with customizable colors
 - **Flexible Content**: Supports multi-line descriptions with proper text wrapping
 - **Consistent Styling**: Uses the app's content card style for visual consistency
 - **Accessibility**: Proper text hierarchy and layout for screen readers
 
 ## Design Elements
 
 - Circular icon container with color theming
 - Clear typography hierarchy with bold titles
 - Flexible description text that adapts to content length
 - Card-style background with rounded corners
 
 ## Usage
 
 ```swift
 TipSectionComponent(
     icon: "timer",
     title: "Perfect Duration",
     description: "Keep videos between 3-5 seconds for best results.",
     color: .green
 )
 ```
 
 - Parameter icon: SF Symbol name for the tip icon
 - Parameter title: Bold title text for the tip
 - Parameter description: Detailed explanation text
 - Parameter color: Theme color for the icon and visual emphasis
 */
struct TipSectionComponent: View {
    
    // MARK: - Properties
    
    /** SF Symbol name for the tip icon. */
    let icon: String
    
    /** Main title text for the tip section. */
    let title: String
    
    /** Detailed description explaining the tip. */
    let description: String
    
    /** Theme color for the icon and visual styling. */
    let color: Color
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            iconContainer
            contentSection
        }
        .contentCardStyle()
    }
    
    // MARK: - Private Views
    
    /**
     The icon container with circular background and themed coloring.
     
     Creates a visually distinctive icon area that draws attention
     and provides consistent theming across different tip sections.
     */
    private var iconContainer: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 48, height: 48)
            
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
        }
    }
    
    /**
     The text content section with title and description.
     
     Provides proper text hierarchy and layout for the tip content,
     ensuring readability and accessibility across different screen sizes.
     */
    private var contentSection: some View {
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
}