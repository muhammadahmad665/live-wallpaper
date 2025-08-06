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
    /// State variable to control showing the tips view
    @State private var showTips: Bool = false
    
    // MARK: - Computed Properties
    
    /// Background gradient for the main view
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.systemBackground).opacity(0.8)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
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
    
    /// Video selection interface
    private var videoSelectionInterface: some View {
        VideoSelectionView(onSelectVideo: { item in
            viewModel.selectedItem = item
        })
    }
    
    /// Video editing interface for selected video
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
            
            bottomActionBar
        }
    }
    
    /// Bottom action bar
    private var bottomActionBar: some View {
        VStack(spacing: 12) {
            Divider()
            
            Button("Choose Different Video") {
                showVideoPicker = true
            }
            .font(.subheadline)
            .foregroundColor(.blue)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.blue.opacity(0.1))
            .clipShape(Capsule())
        }
        .padding()
        .background(.regularMaterial)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                mainContentView
            }
            .navigationTitle("Live Wallpaper Creator")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    navigationMenu
                }
            }
            .onChange(of: viewModel.selectedItem) { _, newItem in
                handleVideoSelection(newItem)
            }
            .alert("Something went wrong", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                errorAlertButtons
            } message: {
                errorAlertMessage
            }
            .alert("🎉 Success!", isPresented: $viewModel.showSuccessMessage) {
                successAlertButtons
            } message: {
                successAlertMessage
            }
            .overlay {
                loadingOverlay
            }
        }
        .sheet(isPresented: $showVideoPicker) {
            videoPickerSheet
        }
        .sheet(isPresented: $showTips) {
            TipsView()
        }
    }
    
    // MARK: - Navigation Components
    
    /// Navigation menu in toolbar
    private var navigationMenu: some View {
        Menu {
            Button(action: {
                showTips = true
            }) {
                Label("Tips & Tricks", systemImage: "lightbulb")
            }
            
            Button(action: {
                // Show about
            }) {
                Label("About", systemImage: "info.circle")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundColor(.blue)
        }
    }
    
    // MARK: - Alert Components
    
    /// Error alert buttons
    private var errorAlertButtons: some View {
        Group {
            Button("Try Again") { viewModel.errorMessage = nil }
            Button("Choose Different Video") { 
                viewModel.errorMessage = nil
                showVideoPicker = true
            }
        }
    }
    
    /// Error alert message
    private var errorAlertMessage: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    /// Success alert buttons
    private var successAlertButtons: some View {
        Group {
            Button("Set as Wallpaper") { 
                if let settingsUrl = URL(string: "App-Prefs:Wallpaper") {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Create Another") { 
                viewModel.resetVideo()
                showVideoPicker = true
            }
            Button("Done") { }
        }
    }
    
    /// Success alert message
    private var successAlertMessage: some View {
        Text("Your Live Wallpaper has been saved to Photos!\n\nTo set it as your wallpaper:\n• Go to Settings > Wallpaper\n• Choose your new Live Photo\n• Set it as Lock Screen")
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
    
    /// Video picker sheet
    private var videoPickerSheet: some View {
        NavigationView {
            VideoSelectionView(onSelectVideo: { item in
                viewModel.resetVideo()
                viewModel.selectedItem = item
                showVideoPicker = false
            })
            .navigationTitle("Choose Video")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showVideoPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Helper Methods
    
    /// Handles video selection from PhotosPicker
    private func handleVideoSelection(_ newItem: PhotosPickerItem?) {
        guard let newItem else { return }
        
        // Haptic feedback for successful selection
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
