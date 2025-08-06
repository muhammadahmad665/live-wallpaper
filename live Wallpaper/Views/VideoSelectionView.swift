//
//  VideoSelectionView.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import PhotosUI

/**
 View for selecting a video from the user's photo library.
 
 This view serves as the initial interface when no video has been selected.
 It provides an engaging introduction to the app's capabilities and guides
 users through the video selection process using PhotosPicker integration.
 
 ## Features
 
 - **Hero Section**: Animated introduction with app branding
 - **Features Overview**: Highlights of app capabilities
 - **Video Selection**: Integrated PhotosPicker for video selection
 - **User Guidance**: Clear instructions and visual cues
 
 ## Architecture
 
 The view is composed of modular components:
 - `HeroSection`: Animated app introduction
 - `FeaturesSection`: Feature highlights
 - `CallToActionSection`: Video selection interface
 
 ## Usage
 
 ```swift
 VideoSelectionView { selectedItem in
     viewModel.selectedItem = selectedItem
 }
 ```
 
 - Parameter onSelectVideo: Callback executed when user selects a video
 - Important: The callback is triggered automatically when PhotosPicker selection changes
 */
struct VideoSelectionView: View {
    
    // MARK: - Properties
    
    /**
     Callback function executed when a video is selected.
     
     This closure is called with the selected PhotosPickerItem when the user
     chooses a video from their photo library. The parent view should use this
     callback to initiate video loading and processing.
     */
    let onSelectVideo: (PhotosPickerItem) -> Void
    
    /**
     Currently selected item from the PhotosPicker.
     
     This state variable tracks the user's selection and triggers the callback
     when changed. It's managed internally by the view and bound to PhotosPicker.
     */
    @State private var selectedItem: PhotosPickerItem?
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Animated hero section with app introduction
                HeroSection()
                
                // App features overview
                FeaturesSection()
                    .padding(.horizontal)
                
                // Video selection call-to-action
                CallToActionSection(selectedItem: $selectedItem)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .onChange(of: selectedItem) { _, newItem in
            // Trigger callback when user selects a video
            if let newItem = newItem {
                onSelectVideo(newItem)
            }
        }
    }
}

// MARK: - Supporting Components

/**
 A reusable component for displaying individual app features.
 
 This component creates a consistent layout for feature descriptions throughout
 the app. It combines an icon, title, and description in a horizontal layout
 that's easy to scan and understand.
 
 ## Design
 
 - Circular icon container with app theme colors
 - Clear hierarchy with bold titles and secondary descriptions
 - Flexible text that adapts to different content lengths
 
 ## Usage
 
 ```swift
 FeatureRow(
     icon: "scissors",
     title: "Smart Trimming", 
     description: "Easily trim your video to the perfect duration"
 )
 ```
 */
struct FeatureRow: View {
    
    // MARK: - Properties
    
    /** SF Symbol name for the feature icon. */
    let icon: String
    
    /** Feature title displayed prominently. */
    let title: String
    
    /** Detailed description of the feature. */
    let description: String
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon container with circular background
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            // Text content with title and description
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
