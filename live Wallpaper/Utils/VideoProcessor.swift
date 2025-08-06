//
//  VideoProcessor.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import AVFoundation
import Photos
import MobileCoreServices
import UIKit
import ImageIO  // Add ImageIO framework for metadata handling
import CoreServices  // Add CoreServices for UTType definitions

/// Enumeration of possible errors during video processing
enum VideoProcessingError: Error {
    /// No video track found in the asset
    case noVideoTrack
    /// Failed to create an export session
    case exportSessionCreationFailed
    /// Export operation failed with a specific reason
    case exportFailed(String)
    /// Failed to convert video to Live Photo format
    case livePhotoConversionFailed
    
    /// Human-readable error descriptions
    var localizedDescription: String {
        switch self {
        case .noVideoTrack:
            return "The selected video doesn't contain a video track"
        case .exportSessionCreationFailed:
            return "Failed to create export session"
        case .exportFailed(let reason):
            return "Export failed: \(reason)"
        case .livePhotoConversionFailed:
            return "Failed to convert video to Live Photo format"
        }
    }
}

/// Utility class for video processing operations
class VideoProcessor {
    /// Trims and speeds up a video to a specific time range and playback speed
    /// - Parameters:
    ///   - url: URL of the source video
    ///   - startTime: Start time in seconds for the trimmed segment
    ///   - endTime: End time in seconds for the trimmed segment
    ///   - speedMultiplier: Speed multiplier (1.0 = normal, 2.0 = 2x speed, etc.)
    ///   - completion: Completion handler with Result containing either the URL of the processed video or an error
    static func trimAndSpeedUpVideo(at url: URL, from startTime: Double, to endTime: Double, speedMultiplier: Double = 1.0, completion: @escaping (Result<URL, Error>) -> Void) {
        // Input validation
        guard startTime >= 0, endTime > startTime, speedMultiplier > 0 else {
            completion(.failure(VideoProcessingError.exportFailed("Invalid time range or speed multiplier")))
            return
        }
        
        let asset = AVAsset(url: url)
        let duration = endTime - startTime
        
        // Validate duration is reasonable (not too short or too long)
        guard duration >= 0.1 && duration <= 300 else { // 0.1 to 300 seconds
            completion(.failure(VideoProcessingError.exportFailed("Video duration must be between 0.1 and 300 seconds")))
            return
        }
        
        // Create composition for speed adjustment
        let composition = AVMutableComposition()
        
        // Set up time range
        let startCMTime = CMTime(seconds: startTime, preferredTimescale: 600)
        let durationCMTime = CMTime(seconds: duration, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: startCMTime, duration: durationCMTime)
        
        do {
            // Add video track
            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                completion(.failure(VideoProcessingError.noVideoTrack))
                return
            }
            
            let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            try compositionVideoTrack?.insertTimeRange(timeRange, of: videoTrack, at: .zero)
            
            // Add audio track if available
            if let audioTrack = asset.tracks(withMediaType: .audio).first {
                let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: .zero)
                
                // Apply speed to audio track
                if speedMultiplier != 1.0 {
                    compositionAudioTrack?.scaleTimeRange(
                        CMTimeRange(start: .zero, duration: durationCMTime),
                        toDuration: CMTime(seconds: duration / speedMultiplier, preferredTimescale: 600)
                    )
                }
            }
            
            // Apply speed to video track
            if speedMultiplier != 1.0 {
                compositionVideoTrack?.scaleTimeRange(
                    CMTimeRange(start: .zero, duration: durationCMTime),
                    toDuration: CMTime(seconds: duration / speedMultiplier, preferredTimescale: 600)
                )
            }
            
            // Create export session
            guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
                completion(.failure(VideoProcessingError.exportSessionCreationFailed))
                return
            }
            
            // Configure export
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let outputURL = documentsPath.appendingPathComponent("trimmed_\(UUID().uuidString).mov")
            
            // Clean up any existing file
            try? FileManager.default.removeItem(at: outputURL)
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mov
            exportSession.shouldOptimizeForNetworkUse = true
            
            // Perform export
            exportSession.exportAsynchronously {
                DispatchQueue.main.async {
                    switch exportSession.status {
                    case .completed:
                        completion(.success(outputURL))
                    case .failed:
                        let error = exportSession.error ?? VideoProcessingError.exportFailed("Unknown error")
                        completion(.failure(error))
                    case .cancelled:
                        completion(.failure(VideoProcessingError.exportFailed("Export was cancelled")))
                    default:
                        completion(.failure(VideoProcessingError.exportFailed("Export failed with status: \(exportSession.status.rawValue)")))
                    }
                }
            }
            
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Legacy method for backward compatibility - trims a video without speed adjustment
    /// - Parameters:
    ///   - url: URL of the source video
    ///   - startTime: Start time in seconds for the trimmed segment
    ///   - endTime: End time in seconds for the trimmed segment
    ///   - completion: Completion handler with Result containing either the URL of the trimmed video or an error
    static func trimVideo(at url: URL, from startTime: Double, to endTime: Double, completion: @escaping (Result<URL, Error>) -> Void) {
        trimAndSpeedUpVideo(at: url, from: startTime, to: endTime, speedMultiplier: 1.0, completion: completion)
    }
    
    /// Converts a video to a format suitable for Live Wallpaper
    /// - Parameters:
    ///   - videoURL: URL of the source video
    ///   - completion: Completion handler with Result containing either the URL of the container directory or an error
    static func convertToLivePhoto(from videoURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        // Extract a frame from the middle of the video for the still image (as mentioned in tips)
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = .zero
        imageGenerator.requestedTimeToleranceAfter = .zero
        
        Task {
            do {
                // Get the duration and calculate middle time
                let duration = try await asset.load(.duration)
                let middleTime = CMTime(seconds: CMTimeGetSeconds(duration) / 2.0, preferredTimescale: 600)
                
                // Generate image from the middle of the video
                let imageRef = try imageGenerator.copyCGImage(at: middleTime, actualTime: nil)
                let image = UIImage(cgImage: imageRef)
                
                // Save the still image to a temporary location
                let tempDir = FileManager.default.temporaryDirectory
                let imagePath = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("heic")
                
                // Use HEIC format for better quality and smaller size
                if let imageData = image.heicData() ?? image.jpegData(compressionQuality: 0.95) {
                    try imageData.write(to: imagePath)
                    
                    // Create container directory for both files
                    let container = tempDir.appendingPathComponent(UUID().uuidString)
                    try FileManager.default.createDirectory(at: container, withIntermediateDirectories: true)
                    
                    // Copy files to the container
                    let finalImagePath = container.appendingPathComponent("stillImage.heic")
                    let finalVideoPath = container.appendingPathComponent("video.mov")
                    
                    try FileManager.default.copyItem(at: imagePath, to: finalImagePath)
                    try FileManager.default.copyItem(at: videoURL, to: finalVideoPath)
                    
                    // Clean up temporary image
                    try? FileManager.default.removeItem(at: imagePath)
                    
                    await MainActor.run {
                        completion(.success(container))
                    }
                } else {
                    await MainActor.run {
                        completion(.failure(VideoProcessingError.livePhotoConversionFailed))
                    }
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Saves a video directly to the Photos library as a Live Photo
    /// - Parameters:
    ///   - videoURL: URL of the source video
    ///   - completion: Completion handler with Result containing success status
    static func saveAsLivePhoto(from videoURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        // Use the LivePhotoUtil Objective-C class for Live Photo creation
        LivePhotoUtil.convertVideo(videoURL.path) { success, message in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else {
                    let error = NSError(
                        domain: "VideoProcessor", 
                        code: -1, 
                        userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to save as Live Photo"]
                    )
                    completion(.failure(error))
                }
            }
        }
    }
}
