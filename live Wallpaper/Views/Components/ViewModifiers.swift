//
//  ViewModifiers.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

/**
 A collection of custom view modifiers for consistent styling throughout the app.
 
 This file contains reusable view modifiers that apply consistent styling patterns
 across the Live Wallpaper Creator app. Using these modifiers ensures visual
 consistency and makes it easy to update styling app-wide.
 
 ## Available Modifiers
 
 - `ContentCardStyle`: Applies card-like styling with padding and background
 - `PrimaryButtonStyle`: Applies primary button styling with state-based colors
 - `AnimatedScaleEffect`: Adds gentle scale animation effects
 
 ## Usage
 
 ```swift
 Text("Content")
     .contentCardStyle()
 
 Button("Action") { }
     .primaryButtonStyle(isEnabled: true)
 
 Image("icon")
     .animatedScaleEffect()
 ```
 */

// MARK: - Content Styling

/**
 A view modifier that applies consistent card-style formatting.
 
 This modifier creates a card-like appearance with padding, subtle background,
 and rounded corners. It's used throughout the app for content sections that
 need visual separation and emphasis.
 
 ## Visual Properties
 
 - Standard padding for comfortable text spacing
 - Light gray background with low opacity
 - 12-point corner radius for modern appearance
 */
struct ContentCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Button Styling

/**
 A view modifier for primary button styling with state management.
 
 This modifier applies the app's primary button appearance including gradient
 backgrounds, proper sizing, and state-based color changes. Disabled buttons
 receive muted styling to indicate their unavailable state.
 
 ## Features
 
 - Gradient background for enabled buttons
 - Muted colors for disabled buttons  
 - Standard button sizing and typography
 - Automatic state management
 */
struct PrimaryButtonStyle: ViewModifier {
    
    // MARK: - Properties
    
    /** Determines whether the button should appear enabled or disabled. */
    let isEnabled: Bool
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                isEnabled 
                    ? LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [.gray, .gray.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(!isEnabled)
    }
}

// MARK: - Animation Effects

/**
 A view modifier that adds gentle scale animation effects.
 
 This modifier applies a subtle, continuous scale animation that creates
 visual interest and draws attention to interactive elements. The animation
 is gentle and non-intrusive, following iOS design principles.
 
 ## Animation Properties
 
 - Scale range: 1.0 to 1.02 (2% increase)
 - Duration: 1.5 seconds
 - Style: Ease-in-out with auto-reverse
 - Repeat: Forever with autoreverses
 */
struct AnimatedScaleEffect: ViewModifier {
    
    // MARK: - State
    
    /** Controls the animation state of the scale effect. */
    @State private var isAnimating = false
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - View Extensions

/**
 Extension to make view modifiers easily accessible as methods.
 
 These convenience methods allow for cleaner, more readable code when applying
 custom view modifiers. They follow SwiftUI conventions for modifier application.
 */
extension View {
    
    /**
     Applies content card styling to the view.
     
     - Returns: The view with card-style formatting applied
     */
    func contentCardStyle() -> some View {
        modifier(ContentCardStyle())
    }
    
    /**
     Applies primary button styling to the view.
     
     - Parameter isEnabled: Whether the button should appear enabled (default: true)
     - Returns: The view with primary button styling applied
     */
    func primaryButtonStyle(isEnabled: Bool = true) -> some View {
        modifier(PrimaryButtonStyle(isEnabled: isEnabled))
    }
    
    /**
     Applies animated scale effects to the view.
     
     - Returns: The view with gentle scale animation applied
     */
    func animatedScaleEffect() -> some View {
        modifier(AnimatedScaleEffect())
    }
}