//
//  ContentView.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import PhotosUI
import AVKit

/// Main content view for the app
/// Coordinates between VideoSelectionView for choosing a video and VideoEditingView for editing it
struct ContentView: View {
    /// ViewModel that manages the video selection and processing logic
    @StateObject private var viewModel = WallpaperViewModel()
    /// State variable to control showing the video picker sheet
    @State private var showVideoPicker: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let selectedVideoURL = viewModel.selectedVideoURL {
                    // Show video editing interface when a video is selected
                    VideoEditingView(
                        videoURL: selectedVideoURL,
                        startTime: $viewModel.startTime,
                        endTime: $viewModel.endTime,
                        videoDuration: viewModel.videoDuration,
                        isProcessing: viewModel.isProcessing,
                        trimmedVideoURL: viewModel.trimmedVideoURL,
                        onProcessVideo: viewModel.processVideo,
                        onSaveVideo: viewModel.saveToPhotoLibrary
                    )
                    
                    // Button to replace the current video with a new selection
                    Button("Replace Video") {
                        showVideoPicker = true
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else {
                    // Show video selection screen when no video is selected
                    VideoSelectionView(onSelectVideo: { item in
                        viewModel.selectedItem = item
                    })
                }
            }
            .padding()
            .navigationTitle("Live Wallpaper Creator")
            // Handle PhotosPickerItem selection
            .onChange(of: viewModel.selectedItem) { _, newItem in
                guard let newItem else { return }
                // Reset existing state before loading a new video
                viewModel.resetVideo()
                viewModel.loadVideo(from: newItem)
            }
            // Error alert for displaying issues
            .alert("Error", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            // Success alert for when wallpaper is created
            .alert("Wallpaper Saved", isPresented: $viewModel.showSuccessMessage) {
                Button("OK") { }
            } message: {
                Text("Your video has been saved to Photos and can be used as a Live Wallpaper.\n\nTo set it up:\n\n1. Go to Settings > Wallpaper > Choose New Wallpaper\n2. Tap on \"All Photos\" or \"Recents\"\n3. Find your video (it will be the most recent one)\n4. Set it as your Lock Screen\n\nTip: Videos between 3-5 seconds work best as Live Wallpapers.")
            }
            // Loading overlay shown during processing
            .overlay {
                if viewModel.isProcessing {
                    LoadingOverlay(message: "Converting your video to Live Wallpaper format")
                }
            }
        }
        // Present video picker sheet when replacing a video
        .sheet(isPresented: $showVideoPicker) {
            VideoSelectionView(onSelectVideo: { item in
                viewModel.resetVideo()
                viewModel.selectedItem = item
                showVideoPicker = false
            })
        }
    }
}

#Preview {
    ContentView()
}
