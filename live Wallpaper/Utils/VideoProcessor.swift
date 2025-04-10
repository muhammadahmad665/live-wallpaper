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
    /// Trims a video to a specific time range
    /// - Parameters:
    ///   - url: URL of the source video
    ///   - startTime: Start time in seconds for the trimmed segment
    ///   - endTime: End time in seconds for the trimmed segment
    ///   - completion: Completion handler with Result containing either the URL of the trimmed video or an error
    static func trimVideo(at url: URL, from startTime: Double, to endTime: Double, completion: @escaping (Result<URL, Error>) -> Void) {
        let asset = AVAsset(url: url)
        let duration = endTime - startTime
        
        // Create export session
        let composition = AVMutableComposition()
        guard let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(.failure(VideoProcessingError.exportSessionCreationFailed))
            return
        }
        
        // Add video track
        do {
            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                throw VideoProcessingError.noVideoTrack
            }
            
            let timeRange = CMTimeRange(
                start: CMTime(seconds: startTime, preferredTimescale: 600),
                duration: CMTime(seconds: duration, preferredTimescale: 600)
            )
            
            try compositionTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)
            
            // Add audio track if available
            if let audioTrack = asset.tracks(withMediaType: .audio).first,
               let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
                try compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: .zero)
            }
        } catch {
            completion(.failure(error))
            return
        }
        
        // Create export session with MOV format (required for Live Photos)
        let tempDir = FileManager.default.temporaryDirectory
        let outputURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(.failure(VideoProcessingError.exportSessionCreationFailed))
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov // Important for Live Photos
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    completion(.success(outputURL))
                case .failed:
                    if let error = exportSession.error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(VideoProcessingError.exportFailed("Unknown error")))
                    }
                case .cancelled:
                    completion(.failure(VideoProcessingError.exportFailed("Export cancelled")))
                default:
                    completion(.failure(VideoProcessingError.exportFailed("Export ended with status: \(exportSession.status.rawValue)")))
                }
            }
        }
    }
    
    /// Converts a video to a format suitable for Live Wallpaper
    /// - Parameters:
    ///   - videoURL: URL of the source video
    ///   - completion: Completion handler with Result containing either the URL of the container directory or an error
    static func convertToLivePhoto(from videoURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        // Extract the first frame of the video for the still image
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            // Get a frame from the beginning of the video
            let time = CMTime(seconds: 0.0, preferredTimescale: 600)
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: imageRef)
            
            // Save the still image to a temporary location
            let tempDir = FileManager.default.temporaryDirectory
            let imagePath = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            
            if let imageData = image.jpegData(compressionQuality: 0.95) {
                try imageData.write(to: imagePath)
                
                // Just return both the video and image URL as a dictionary for simplicity
                let container = tempDir.appendingPathComponent(UUID().uuidString)
                try FileManager.default.createDirectory(at: container, withIntermediateDirectories: true)
                
                // Copy files to the container
                let finalImagePath = container.appendingPathComponent("stillImage.jpg")
                let finalVideoPath = container.appendingPathComponent("video.mov")
                
                try FileManager.default.copyItem(at: imagePath, to: finalImagePath)
                try FileManager.default.copyItem(at: videoURL, to: finalVideoPath)
                
                completion(.success(container))
            } else {
                completion(.failure(VideoProcessingError.livePhotoConversionFailed))
            }
        } catch {
            completion(.failure(error))
        }
    }
}
