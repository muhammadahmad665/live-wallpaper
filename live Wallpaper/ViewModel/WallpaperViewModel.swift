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
import UIKit
import Photos

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
    /// Speed multiplier for the video (1.0 = normal, 2.0 = 2x speed, etc.)
    @Published var speedMultiplier: Double = 1.0
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
        speedMultiplier = 1.0
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
        
        // Haptic feedback for processing start
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        isProcessing = true
        VideoProcessor.trimAndSpeedUpVideo(
            at: selectedVideoURL,
            from: startTime,
            to: endTime,
            speedMultiplier: speedMultiplier
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let trimmedURL):
                self.trimmedVideoURL = trimmedURL
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.showSuccessMessage = true
                    
                    // Success haptic feedback
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = error.localizedDescription
                    
                    // Error haptic feedback
                    let errorFeedback = UINotificationFeedbackGenerator()
                    errorFeedback.notificationOccurred(.error)
                }
            }
        }
    }
    
    /// Creates a video wallpaper by processing the video and saving it to the photo library
    /// This is the complete workflow that users expect when clicking "Create Video Wallpaper"
    func createLiveWallpaper() {
        guard let selectedVideoURL = selectedVideoURL else { return }
        
        // Haptic feedback for processing start
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        isProcessing = true
        
        // Add a timeout to prevent infinite hanging
        let timeoutTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timeoutTimer.schedule(deadline: .now() + 60) // 60 second timeout
        timeoutTimer.setEventHandler { [weak self] in
            guard let self = self else { return }
            
            if self.isProcessing {
                self.isProcessing = false
                self.errorMessage = "Video wallpaper creation timed out. Please try again with a shorter video clip."
                
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
            }
            timeoutTimer.cancel()
        }
        timeoutTimer.resume()
        
        // Step 1: Trim and speed up the video
        VideoProcessor.trimAndSpeedUpVideo(
            at: selectedVideoURL,
            from: startTime,
            to: endTime,
            speedMultiplier: speedMultiplier
        ) { [weak self] result in
            guard let self = self else { 
                timeoutTimer.cancel()
                return 
            }
            
            switch result {
            case .success(let trimmedURL):
                // Step 2: Save the trimmed video as a Live Photo
                self.trimmedVideoURL = trimmedURL
                
                // Request photo library permissions first
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
                    guard let self = self else { 
                        timeoutTimer.cancel()
                        return 
                    }
                    
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized, .limited:
                            // Permission granted, proceed with saving
                            VideoProcessor.saveAsLivePhoto(from: trimmedURL) { [weak self] saveResult in
                                guard let self = self else { 
                                    timeoutTimer.cancel()
                                    return 
                                }
                                
                                DispatchQueue.main.async {
                                    timeoutTimer.cancel()
                                    self.isProcessing = false
                                    
                                    switch saveResult {
                                    case .success:
                                        self.showSuccessMessage = true
                                        
                                        // Success haptic feedback
                                        let successFeedback = UINotificationFeedbackGenerator()
                                        successFeedback.notificationOccurred(.success)
                                        
                                    case .failure(let error):
                                        self.errorMessage = "Failed to save video wallpaper: \(error.localizedDescription)"
                                        
                                        // Error haptic feedback
                                        let errorFeedback = UINotificationFeedbackGenerator()
                                        errorFeedback.notificationOccurred(.error)
                                    }
                                }
                            }
                            
                        case .denied, .restricted:
                            timeoutTimer.cancel()
                            self.isProcessing = false
                            self.errorMessage = "Photo library access is required to save video wallpapers. Please grant permission in Settings."
                            
                            let errorFeedback = UINotificationFeedbackGenerator()
                            errorFeedback.notificationOccurred(.error)
                            
                        case .notDetermined:
                            timeoutTimer.cancel()
                            self.isProcessing = false
                            self.errorMessage = "Photo library permission not determined. Please try again."
                            
                            let errorFeedback = UINotificationFeedbackGenerator()
                            errorFeedback.notificationOccurred(.error)
                            
                        @unknown default:
                            timeoutTimer.cancel()
                            self.isProcessing = false
                            self.errorMessage = "Unknown photo library permission status. Please try again."
                            
                            let errorFeedback = UINotificationFeedbackGenerator()
                            errorFeedback.notificationOccurred(.error)
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    timeoutTimer.cancel()
                    self.isProcessing = false
                    self.errorMessage = "Failed to process video: \(error.localizedDescription)"
                    
                    // Error haptic feedback
                    let errorFeedback = UINotificationFeedbackGenerator()
                    errorFeedback.notificationOccurred(.error)
                }
            }
        }
    }
    
    /// Saves the processed video as a Live Photo to the photo library
    /// Uses VideoProcessor.saveAsLivePhoto to handle the conversion process
    func saveToPhotoLibrary() {
        guard let trimmedVideoURL = trimmedVideoURL else {
            errorMessage = "No processed video available to save"
            return
        }
        
        // Haptic feedback for save start
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        isProcessing = true
        
        // Use the VideoProcessor.saveAsLivePhoto method for a cleaner implementation
        VideoProcessor.saveAsLivePhoto(from: trimmedVideoURL) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isProcessing = false
                
                switch result {
                case .success:
                    self.showSuccessMessage = true
                    
                    // Success haptic feedback
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    
                    // Error haptic feedback
                    let errorFeedback = UINotificationFeedbackGenerator()
                    errorFeedback.notificationOccurred(.error)
                }
            }
        }
    }
    
    
    /// Gets the recommended speed multiplier based on video duration
    /// - Parameter duration: The duration of the video segment
    /// - Returns: Recommended speed multiplier
    func getRecommendedSpeed(for duration: Double) -> Double {
        // For longer clips, recommend higher speeds to fit more action
        if duration > 4.0 {
            return 2.0  // 2x speed for longer clips
        } else if duration > 3.0 {
            return 1.5  // 1.5x speed for medium clips
        } else {
            return 1.0  // Normal speed for short clips
        }
    }
    
    /// Simple save to photos - saves the optimized video directly to the photo library
    /// - Parameter url: URL of the video to save
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
    
    /// Creates an optimized video for Live Photo usage
    /// - Parameters:
    ///   - videoURL: Source video URL
    ///   - completion: Completion handler with the result
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
