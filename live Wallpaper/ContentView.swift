//
//  ContentView.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import PhotosUI
import AVKit

/**
 Main content view for the Live Wallpaper Creator app.
 
 This view serves as the primary container and coordinator for the entire application flow.
 It manages the transition between video selection and video editing interfaces, handles
 global app state, and provides navigation and alert functionality.
 
 ## Overview
 
 The `ContentView` follows a state-based architecture where it presents different interfaces
 based on the current state of video selection:
 - When no video is selected: Shows `VideoSelectionView`
 - When a video is selected: Shows `VideoEditingView`
 
 ## Key Responsibilities
 
 - **State Management**: Manages the primary app state through `WallpaperViewModel`
 - **Navigation**: Handles sheet presentations for video picker and tips
 - **User Feedback**: Manages error and success alerts
 - **Interface Coordination**: Orchestrates between selection and editing views
 
 ## Usage
 
 ```swift
 ContentView()
 ```
 
 - Note: This view automatically creates and manages its own `WallpaperViewModel` instance.
 - Important: The view uses `@StateObject` for the view model to ensure proper lifecycle management.
 */
struct ContentView: View {
    
    // MARK: - Properties
    
    /**
     The view model that manages video selection, processing, and app state.
     
     This property uses `@StateObject` to ensure the view model is created once
     and persists throughout the view's lifetime. It handles all business logic
     including video loading, processing, and saving operations.
     */
    @StateObject private var viewModel = WallpaperViewModel()
    
    /**
     Controls the presentation of the video picker sheet.
     
     When `true`, presents a sheet allowing users to select a different video
     from their photo library. Used both for initial selection and changing videos.
     */
    @State private var showVideoPicker: Bool = false
    
    /**
     Controls the presentation of the tips and help sheet.
     
     When `true`, presents a sheet containing helpful tips and best practices
     for creating effective Live Wallpapers.
     */
    @State private var showTips: Bool = false
    
    // MARK: - Computed Properties
    
    /**
     The main content view that switches between video selection and editing interfaces.
     
     This computed property determines which interface to show based on whether
     a video has been selected. It provides a clean separation between the two
     main app states.
     
     - Returns: A view containing either the video selection or editing interface
     */
    
    /// Main content based on current state
    private var mainContentView: some View {
        VStack(spacing: 0) {
            if let selectedVideoURL = viewModel.selectedVideoURL {
                videoEditingInterface(for: selectedVideoURL)
            } else {
                videoSelectionInterface
            }
        }
    }
    
    /**
     The video selection interface component.
     
     This computed property provides a clean interface for video selection
     that handles the callback when a user selects a video from their library.
     
     - Returns: A `VideoSelectionView` configured with the appropriate callback
     */
    private var videoSelectionInterface: some View {
        VideoSelectionView(onSelectVideo: { item in
            viewModel.selectedItem = item
        })
    }
    
    /**
     Creates the video editing interface for a selected video.
     
     This method constructs the complete video editing interface with all necessary
     bindings and callbacks. It handles the complex coordination between video
     editing components and the view model.
     
     - Parameter selectedVideoURL: The URL of the selected video to edit
     - Returns: A view containing the complete video editing interface
     
     ## Key Features
     
     - Video trimming and preview
     - Speed control
     - Processing and saving functionality
     - Integrated action handling
     */
    private func videoEditingInterface(for selectedVideoURL: URL) -> some View {
        VStack(spacing: 0) {
            VideoEditingView(
                videoURL: selectedVideoURL,
                startTime: $viewModel.startTime,
                endTime: $viewModel.endTime,
                speedMultiplier: $viewModel.speedMultiplier,
                videoDuration: viewModel.videoDuration,
                isProcessing: viewModel.isProcessing,
                trimmedVideoURL: viewModel.trimmedVideoURL,
                onProcessVideo: viewModel.processVideo,
                onSaveVideo: viewModel.saveToPhotoLibrary,
                onCreateLiveWallpaper: {
                    print("🎬 onCreateLiveWallpaper called!")
                    print("🎬 trimmedVideoURL exists: \(viewModel.trimmedVideoURL != nil)")
                    
                    // Unified action that handles both processing and saving
                    if viewModel.trimmedVideoURL != nil {
                        print("🎬 Video already processed, saving to library...")
                        viewModel.saveToPhotoLibrary()
                    } else {
                        print("🎬 Video not processed yet, processing first...")
                        viewModel.processVideo()
                    }
                }
            )
            
            BottomActionBar(showVideoPicker: $showVideoPicker)
        }
    }
    
    
    // MARK: - Body
    
    /**
     The main body of the content view.
     
     Constructs the complete user interface including navigation, background,
     content areas, alerts, and sheet presentations. Uses a `NavigationStack`
     as the root container to provide navigation context.
     
     ## Interface Elements
     
     - **Background**: Custom gradient background
     - **Main Content**: State-dependent content (selection or editing)
     - **Navigation**: Toolbar with menu options
     - **Alerts**: Error and success feedback
     - **Sheets**: Video picker and tips presentations
     
     - Returns: The complete user interface view hierarchy
     */
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient()
                mainContentView
            }
            .navigationTitle("Live Wallpaper Creator")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationMenu(showTips: $showTips)
                }
            }
            .onChange(of: viewModel.selectedItem) { _, newItem in
                handleVideoSelection(newItem)
            }
            .alert("Something went wrong", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                ErrorAlertButtons(
                    showVideoPicker: $showVideoPicker,
                    onDismiss: { viewModel.errorMessage = nil }
                )
            } message: {
                ErrorAlertMessage(errorMessage: viewModel.errorMessage)
            }
            .alert("🎉 Success!", isPresented: $viewModel.showSuccessMessage) {
                SuccessAlertButtons(
                    showVideoPicker: $showVideoPicker,
                    onReset: { viewModel.resetVideo() }
                )
            } message: {
                SuccessAlertMessage()
            }
            .overlay {
                loadingOverlay
            }
        }
        .sheet(isPresented: $showVideoPicker) {
            VideoPickerSheet(
                showVideoPicker: $showVideoPicker,
                onSelectVideo: { item in viewModel.selectedItem = item },
                onReset: { viewModel.resetVideo() }
            )
        }
        .sheet(isPresented: $showTips) {
            TipsView()
        }
    }
    
    
    /// Loading overlay
    private var loadingOverlay: some View {
        Group {
            if viewModel.isProcessing {
                LoadingOverlay(message: "Creating Live Wallpaper")
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
    
    
    // MARK: - Helper Methods
    
    /**
     Handles the selection of a new video item from the PhotosPicker.
     
     This method processes the video selection, provides haptic feedback,
     resets any existing video state, and initiates the loading of the new video.
     It's called automatically when the `selectedItem` in the view model changes.
     
     - Parameter newItem: The newly selected `PhotosPickerItem`, or `nil` if selection was cleared
     
     ## Behavior
     
     - Provides haptic feedback on successful selection
     - Resets existing video state before loading new video
     - Initiates video loading process through the view model
     - Gracefully handles `nil` selections
     */
    private func handleVideoSelection(_ newItem: PhotosPickerItem?) {
        guard let newItem else { return }
        
        // Provide haptic feedback for successful selection
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Reset existing state before loading a new video
        viewModel.resetVideo()
        viewModel.loadVideo(from: newItem)
    }
}

#Preview {
    ContentView()
}
