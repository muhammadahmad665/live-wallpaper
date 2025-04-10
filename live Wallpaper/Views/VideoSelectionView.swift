//
//  VideoSelectionView.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import PhotosUI

/// View for selecting a video from the user's photo library
/// Displays introductory information and a button to launch the PhotosPicker
struct VideoSelectionView: View {
    /// Callback function to execute when a video is selected
    let onSelectVideo: (PhotosPickerItem) -> Void
    /// Currently selected item from the picker (if any)
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 20) {
            // App icon/illustration
            Image(systemName: "photo.on.rectangle.angled")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            // Main headline
            Text("Select a video to convert to a Live Wallpaper")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            // Instructional text explaining the app's functionality
            Text("Trim your video to a maximum of 5 seconds and save it to use as a Live Wallpaper on your iPhone.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            
            // PhotosPicker button to select a video
            PhotosPicker(selection: $selectedItem,
                        matching: .videos,
                        photoLibrary: .shared()) {
                Text("Select Video")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .onChange(of: selectedItem) { _, newItem in
                if let newItem = newItem {
                    onSelectVideo(newItem)
                }
            }
        }
    }
}
