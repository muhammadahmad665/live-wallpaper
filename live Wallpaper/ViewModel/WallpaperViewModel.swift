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

/**
 ViewModel responsible for handling video selection, processing, and saving as Live Photos.
 
 This class acts as the central coordinator between the user interface and underlying
 video processing logic. It manages the complete workflow from video selection through
 processing to Live Photo creation and saving.
 
 ## Key Responsibilities
 
 - **Video Selection**: Handles loading videos from PhotosPicker
 - **Video Processing**: Manages trimming and speed adjustment operations
 - **Live Photo Creation**: Coordinates conversion to Live Photo format
 - **State Management**: Maintains app state and provides reactive updates
 - **Error Handling**: Provides comprehensive error reporting and user feedback
 
 ## Architecture
 
 The view model follows the MVVM pattern and uses `@Published` properties to provide
 reactive updates to the user interface. All async operations are properly handled
 with completion callbacks and main queue dispatch for UI updates.
 
 ## Usage
 
 ```swift
 @StateObject private var viewModel = WallpaperViewModel()
 ```
 
 - Note: Use `@StateObject` to ensure proper lifecycle management
 - Important: All UI-related operations are automatically dispatched to the main queue
 */
class WallpaperViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /**
     The currently selected item from the PhotosPicker.
     
     This property is automatically updated when a user selects a video from
     their photo library. Changes to this property trigger the video loading process.
     */
    @Published var selectedItem: PhotosPickerItem?
    
    /**
     URL of the currently selected video file.
     
     This URL is set after successfully loading a video from the PhotosPicker.
     It represents the original, unprocessed video file.
     */
    @Published var selectedVideoURL: URL?
    
    /**
     URL of the processed (trimmed and speed-adjusted) video.
     
     This URL is available after successful video processing and represents
     the final video that will be converted to a Live Photo.
     */
    @Published var trimmedVideoURL: URL?
    
    /**
     Start time in seconds for video trimming.
     
     Represents the beginning of the selected video segment. Must be less than `endTime`.
     Default value is 0 (start of video).
     */
    @Published var startTime: Double = 0
    
    /**
     End time in seconds for video trimming.
     
     Represents the end of the selected video segment. The duration (`endTime - startTime`)
     should not exceed 5 seconds after speed adjustment for optimal Live Photo performance.
     Default value is 5 seconds.
     */
    @Published var endTime: Double = 5
    
    /**
     Speed multiplier for the video processing.
     
     - `1.0`: Normal speed (no change)
     - `2.0`: Double speed (2x faster)
     - `0.5`: Half speed (2x slower)
     
     Higher values create more dynamic wallpapers by packing more motion into the final duration.
     Default value is 1.0 (normal speed).
     */
    @Published var speedMultiplier: Double = 1.0
    
    /**
     Total duration of the selected video in seconds.
     
     This value is automatically set when a video is loaded and represents
     the full duration of the original video file.
     */
    @Published var videoDuration: Double = 0
    
    /**
     Indicates whether video processing is currently in progress.
     
     When `true`, the UI should show loading indicators and disable interaction
     with processing controls to prevent multiple concurrent operations.
     */
    @Published var isProcessing = false
    
    /**
     Controls the display of success messages.
     
     Set to `true` when a Live Photo has been successfully saved to the photo library.
     The UI should bind to this property to show success alerts.
     */
    @Published var showSuccessMessage = false
    
    /**
     Contains error messages for display to the user.
     
     When not `nil`, contains a user-readable error message that should be
     displayed in an alert or other error UI. Set to `nil` to dismiss error states.
     */
    @Published var errorMessage: String?
    
    /**
     URL of the created Live Photo (if available).
     
     This property is currently not used in the main flow but is available
     for future enhancements or debugging purposes.
     */
    @Published var livePhotoURL: URL?
    
    // MARK: - Public Methods
    
    /**
     Resets all video-related state to initial values.
     
     This method clears all video-specific state and returns the view model
     to its initial configuration. It's typically called when selecting a new
     video or when the user chooses to start over.
     
     ## Reset State
     
     - Clears selected item and video URLs
     - Resets time range to 0-5 seconds
     - Resets speed multiplier to 1.0x
     - Clears video duration
     
     - Note: This method does not reset error messages or processing states
     */
    func resetVideo() {
        selectedItem = nil
        selectedVideoURL = nil
        trimmedVideoURL = nil
        startTime = 0
        endTime = 5
        speedMultiplier = 1.0
        videoDuration = 0
    }
    
    /**
     Loads video data from a selected PhotosPickerItem.
     
     This method handles the asynchronous loading of video data from the user's
     photo library. It extracts the video file, determines its properties, and
     updates the view model state accordingly.
     
     - Parameter item: The selected photo library item containing a video
     
     ## Async Behavior
     
     This method performs asynchronous operations:
     1. Loads the transferable video file
     2. Extracts video duration and properties
     3. Updates UI state on the main queue
     
     ## Error Handling
     
     - Sets `errorMessage` if loading fails
     - Provides detailed error information for debugging
     - All errors are handled gracefully without crashing
     
     - Important: All UI updates are automatically dispatched to the main queue
     */
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
    
    /**
     Processes the selected video by trimming and applying speed adjustments.
     
     This method performs the core video processing operation, taking the selected
     video segment and applying the user's chosen speed multiplier. The result is
     a processed video ready for Live Photo conversion.
     
     ## Processing Steps
     
     1. Validates that a video is selected
     2. Provides haptic feedback to the user
     3. Calls VideoProcessor to perform trimming and speed adjustment
     4. Updates state based on processing results
     
     ## State Updates
     
     - Sets `isProcessing` to `true` during operation
     - Updates `trimmedVideoURL` on success
     - Sets `errorMessage` on failure
     - Provides appropriate haptic feedback for outcomes
     
     - Requires: `selectedVideoURL` must not be `nil`
     - Important: This method should only be called when video processing is allowed
     */
    func processVideo() {
        guard let selectedVideoURL = selectedVideoURL else { return }
        
        print("🎬 Starting video processing...")
        print("🎬 Settings - Start: \(startTime)s, End: \(endTime)s, Speed: \(speedMultiplier)x")
        print("🎬 Duration: \(endTime - startTime)s -> Final: \((endTime - startTime) / speedMultiplier)s")
        
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
                print("🎬 ✅ Video processing completed: \(trimmedURL.lastPathComponent)")
                self.trimmedVideoURL = trimmedURL
                DispatchQueue.main.async {
                    self.isProcessing = false
                    // Don't show success message here - only after Live Photo is saved
                    
                    // Success haptic feedback
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                }
            case .failure(let error):
                print("🎬 ❌ Video processing failed: \(error.localizedDescription)")
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
    
    /**
     Saves the processed video as a Live Photo to the photo library.
     
     This method takes the processed video and converts it to a Live Photo format
     before saving it to the user's photo library. It handles photo library permissions
     and provides appropriate feedback throughout the process.
     
     ## Process Flow
     
     1. Validates that a processed video exists
     2. Requests photo library authorization if needed
     3. Converts video to Live Photo format
     4. Saves to photo library
     5. Provides user feedback
     
     ## State Updates
     
     - Sets `isProcessing` to `true` during operation
     - Sets `showSuccessMessage` on successful save
     - Sets `errorMessage` on failure
     - Provides haptic feedback for all outcomes
     
     ## Permissions
     
     This method handles photo library permissions automatically and will
     show appropriate error messages if access is denied.
     
     - Requires: `trimmedVideoURL` must not be `nil`
     - Important: Requires photo library access permissions
     */
    func saveToPhotoLibrary() {
        guard let trimmedVideoURL = trimmedVideoURL else {
            print("❌ No processed video available to save")
            errorMessage = "No processed video available to save"
            return
        }
        
        print("🎬 Starting Live Photo save process...")
        print("🎬 Video URL: \(trimmedVideoURL.lastPathComponent)")
        print("🎬 Original settings - Start: \(startTime)s, End: \(endTime)s, Speed: \(speedMultiplier)x")
        print("🎬 Duration: \(endTime - startTime)s -> Final: \((endTime - startTime) / speedMultiplier)s")
        
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
                    print("🎬 ✅ Live Photo saved successfully!")
                    self.showSuccessMessage = true
                    
                    // Success haptic feedback
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                    
                case .failure(let error):
                    print("🎬 ❌ Live Photo save failed: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    
                    // Error haptic feedback
                    let errorFeedback = UINotificationFeedbackGenerator()
                    errorFeedback.notificationOccurred(.error)
                }
            }
        }
    }
    
    
    /**
     Gets the recommended speed multiplier based on video duration.
     
     This method provides intelligent speed recommendations based on the duration
     of the selected video segment. Longer segments benefit from higher speeds
     to pack more motion into the final Live Photo.
     
     - Parameter duration: The duration of the video segment in seconds
     - Returns: Recommended speed multiplier (1.0, 1.5, or 2.0)
     
     ## Recommendation Logic
     
     - **> 4.0 seconds**: 2.0x speed (more dramatic effect)
     - **> 3.0 seconds**: 1.5x speed (moderate enhancement)
     - **≤ 3.0 seconds**: 1.0x speed (natural timing)
     
     - Note: These recommendations optimize for the 5-second Live Photo limit
     */
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
    
    // MARK: - Private Methods
    
    /**
     Saves an optimized video directly to the photo library.
     
     This private method handles the low-level photo library operations for saving
     a video file. It manages permissions and provides appropriate error handling.
     
     - Parameter url: URL of the video file to save
     
     ## Process
     
     1. Requests photo library authorization
     2. Creates a PHAssetCreationRequest
     3. Adds video resource to the request
     4. Executes the save operation
     
     - Important: This is a private helper method, not part of the main workflow
     - Note: The main flow uses Live Photo creation instead of direct video saving
     */
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
    
    /**
     Creates an optimized video for Live Photo usage.
     
     This private method handles video optimization and format conversion to ensure
     compatibility with Live Photo requirements. It uses AVAssetExportSession to
     perform the conversion with appropriate quality settings.
     
     - Parameters:
        - videoURL: Source video URL to optimize
        - completion: Completion handler with the result (success with URL or failure with error)
     
     ## Optimization Process
     
     1. Creates AVAssetExportSession with highest quality preset
     2. Sets output format to .mov (required for Live Photos)
     3. Exports to temporary directory with unique filename
     4. Calls completion handler with results
     
     ## Error Handling
     
     Handles various export failures:
     - Export session creation failure
     - Export process errors
     - Unknown export status issues
     
     - Important: This is a private helper method for future enhancements
     - Note: Currently not used in the main application flow
     */
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
