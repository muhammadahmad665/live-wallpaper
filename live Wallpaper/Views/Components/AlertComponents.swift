//
//  AlertComponents.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

/**
 A collection of reusable alert components for the Live Wallpaper Creator app.
 
 This file contains specialized view components for handling different types of
 user alerts including error messages, success notifications, and their associated
 action buttons. All components follow Apple's Human Interface Guidelines for alerts.
 */

// MARK: - Error Alert Components

/**
 Action buttons for error alert dialogs.
 
 Provides standard error handling actions including retry and video selection options.
 The buttons are designed to give users clear recovery paths when errors occur.
 
 ## Usage
 
 ```swift
 ErrorAlertButtons(
     showVideoPicker: $showVideoPicker,
     onDismiss: { viewModel.errorMessage = nil }
 )
 ```
 */
struct ErrorAlertButtons: View {
    
    // MARK: - Properties
    
    /** Controls the presentation of the video picker sheet. */
    @Binding var showVideoPicker: Bool
    
    /** Closure called when the error should be dismissed. */
    let onDismiss: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Group {
            Button("Try Again") { onDismiss() }
            Button("Choose Different Video") { 
                onDismiss()
                showVideoPicker = true
            }
        }
    }
}

/**
 Message content for error alert dialogs.
 
 Displays error messages in a consistent format within alert dialogs.
 Handles nil error messages gracefully.
 
 ## Usage
 
 ```swift
 ErrorAlertMessage(errorMessage: viewModel.errorMessage)
 ```
 */
struct ErrorAlertMessage: View {
    
    // MARK: - Properties
    
    /** The error message to display, or nil if no error. */
    let errorMessage: String?
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
}

// MARK: - Success Alert Components

/**
 Action buttons for success alert dialogs.
 
 Provides post-success actions including wallpaper setup guidance and
 options to create additional wallpapers. Designed to guide users through
 the complete wallpaper setup process.
 
 ## Usage
 
 ```swift
 SuccessAlertButtons(
     showVideoPicker: $showVideoPicker,
     onReset: { viewModel.resetVideo() }
 )
 ```
 */
struct SuccessAlertButtons: View {
    
    // MARK: - Properties
    
    /** Controls the presentation of the video picker sheet. */
    @Binding var showVideoPicker: Bool
    
    /** Closure called to reset the app state for creating another wallpaper. */
    let onReset: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Group {
            Button("Set as Wallpaper") { 
                if let settingsUrl = URL(string: "App-Prefs:Wallpaper") {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Create Another") { 
                onReset()
                showVideoPicker = true
            }
            Button("Done") { }
        }
    }
}

/**
 Message content for success alert dialogs.
 
 Displays a comprehensive success message with instructions for setting
 the created Live Photo as a wallpaper. Provides clear step-by-step guidance.
 
 ## Usage
 
 ```swift
 SuccessAlertMessage()
 ```
 */
struct SuccessAlertMessage: View {
    // MARK: - Body
    
    var body: some View {
        Text("Your Live Wallpaper has been saved to Photos!\n\nTo set it as your wallpaper:\n• Go to Settings > Wallpaper\n• Choose your new Live Photo\n• Set it as Lock Screen")
    }
}