//
//  WallpaperViewModel.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import PhotosUI
import AVKit
import UniformTypeIdentifiers

/// ViewModel responsible for handling video selection, processing, and saving as Live Photos
/// Acts as the central coordinator between UI and underlying video processing logic
class WallpaperViewModel: ObservableObject {
    /// The currently selected item from the PhotosPicker
    @Published var selectedItem: PhotosPickerItem?
    /// URL of the selected video file
    @Published var selectedVideoURL: URL?
    /// URL of the processed (trimmed) video
    @Published var trimmedVideoURL: URL?
    /// Start time in seconds for video trimming
    @Published var startTime: Double = 0
    /// End time in seconds for video trimming (maximum 5 seconds)
    @Published var endTime: Double = 5
    /// Total duration of the selected video in seconds
    @Published var videoDuration: Double = 0
    /// Flag indicating if processing is currently in progress
    @Published var isProcessing = false
    /// Flag to control showing success message
    @Published var showSuccessMessage = false
    /// Error message to display if something goes wrong
    @Published var errorMessage: String?
    /// URL of the created Live Photo if available
    @Published var livePhotoURL: URL?
    
    /// Resets all video-related state to initial values
    /// Used when selecting a new video or clearing the current selection
    func resetVideo() {
        selectedItem = nil
        selectedVideoURL = nil
        trimmedVideoURL = nil
        startTime = 0
        endTime = 5
        videoDuration = 0
    }
    
    /// Loads video data from a selected PhotosPickerItem
    /// - Parameter item: The selected photo library item containing a video
    func loadVideo(from item: PhotosPickerItem) {
        print("Loading video from PhotosPickerItem")
        
        // Use the custom VideoFile transferable
        item.loadTransferable(type: VideoFile.self) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let videoFile):
                if let videoFile = videoFile {
                    print("Successfully loaded video file at: \(videoFile.url)")
                    
                    DispatchQueue.main.async {
                        self.selectedVideoURL = videoFile.url
                        
                        // Get video duration
                        let asset = AVAsset(url: videoFile.url)
                        Task {
                            do {
                                let duration = try await asset.load(.duration).seconds
                                print("Video duration: \(duration) seconds")
                                self.videoDuration = duration
                                self.endTime = min(5, duration)
                            } catch {
                                print("Error loading duration: \(error)")
                                self.errorMessage = "Failed to load video duration: \(error.localizedDescription)"
                            }
                        }
                    }
                } else {
                    print("VideoFile is nil")
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to load video: VideoFile is nil"
                    }
                }
                
            case .failure(let error):
                print("Error loading video: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load video: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Processes the selected video by trimming it to the selected time range
    /// Updates trimmedVideoURL on success or errorMessage on failure
    func processVideo() {
        guard let selectedVideoURL = selectedVideoURL else { return }
        
        isProcessing = true
        VideoProcessor.trimVideo(at: selectedVideoURL, from: startTime, to: endTime) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let trimmedURL):
                self.trimmedVideoURL = trimmedURL
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.showSuccessMessage = true 
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    /// Saves the processed video as a Live Photo to the photo library
    /// Uses LivePhotoUtil to handle the conversion process
    func saveToPhotoLibrary() {
        guard let trimmedVideoURL = trimmedVideoURL else {
            self.errorMessage = "No processed video to save"
            return
        }
        
        isProcessing = true
        
        // Use LivePhotoUtil.convertVideo with the video file path.
        LivePhotoUtil.convertVideo(trimmedVideoURL.path) { success, message in
            DispatchQueue.main.async {
                self.isProcessing = false
                if success {
                    self.showSuccessMessage = true
                } else {
                    self.errorMessage = "Live Photo conversion failed: \(message)"
                }
            }
        }
    }
    
    // Simple save to photos
    private func saveOptimizedVideoToPhotoLibrary(url: URL) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            
            guard status == .authorized else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = "Photo library access is required to save the wallpaper"
                }
                return
            }
            
            // Save the video to the photo library
            PHPhotoLibrary.shared().performChanges {
                let options = PHAssetResourceCreationOptions()
                options.shouldMoveFile = false
                
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .video, fileURL: url, options: options)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    self.isProcessing = false
                    
                    if success {
                        self.showSuccessMessage = true
                    } else if let error = error {
                        self.errorMessage = "Failed to save video: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    // Replace the current createOptimizedVideo implementation with:
    private func createOptimizedVideo(from videoURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let asset = AVAsset(url: videoURL)
        let tempDir = FileManager.default.temporaryDirectory
        let outputURL = tempDir.appendingPathComponent("LiveWallpaper-\(UUID().uuidString)").appendingPathExtension("mov")
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(.failure(NSError(domain: "WallpaperViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not create export session"])))
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov // Required format
        
        // Asynchronously export the video and call completion on main queue
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed {
                    completion(.success(outputURL))
                } else if let error = exportSession.error {
                    completion(.failure(error))
                } else {
                    completion(.failure(NSError(domain: "WallpaperViewModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unknown export status"])))
                }
            }
        }
    }
}
