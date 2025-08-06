//
//  NavigationComponents.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

/**
 A reusable navigation menu component for the app's toolbar.
 
 This component provides a dropdown menu with navigation options including
 tips and about sections. It's designed to be used in the main app toolbar
 and follows iOS design patterns for navigation menus.
 
 ## Features
 
 - Tips & Tricks navigation
 - About section (placeholder for future implementation)
 - Consistent iOS menu styling
 - Binding-based state management
 
 ## Usage
 
 ```swift
 NavigationMenu(showTips: $showTips)
 ```
 
 - Parameter showTips: Binding to control the tips sheet presentation
 */
struct NavigationMenu: View {
    
    // MARK: - Properties
    
    /**
     Controls the presentation of the tips sheet.
     
     When this binding is set to `true`, the tips and help interface
     should be presented to the user.
     */
    @Binding var showTips: Bool
    
    // MARK: - Body
    
    var body: some View {
        Menu {
            Button(action: {
                showTips = true
            }) {
                Label("Tips & Tricks", systemImage: "lightbulb")
            }
            
            Button(action: {
                // Show about - placeholder for future implementation
            }) {
                Label("About", systemImage: "info.circle")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundColor(.blue)
        }
    }
}