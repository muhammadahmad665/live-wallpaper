//
//  VideoSelectionInterface.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import PhotosUI

struct VideoSelectionInterface: View {
    let onSelectVideo: (PhotosPickerItem) -> Void
    
    var body: some View {
        VideoSelectionView(onSelectVideo: onSelectVideo)
    }
}

struct VideoPickerSheet: View {
    @Binding var showVideoPicker: Bool
    let onSelectVideo: (PhotosPickerItem) -> Void
    let onReset: () -> Void
    
    var body: some View {
        NavigationView {
            VideoSelectionView(onSelectVideo: { item in
                onReset()
                onSelectVideo(item)
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
}