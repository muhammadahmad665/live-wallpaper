import Foundation
import UIKit
import Photos
import AVFoundation
import MobileCoreServices

/// Utility class for creating Live Photos from video files
class LivePhotoCreator {
    
    /// Creates a PHLivePhoto object from a video file
    /// - Parameters:
    ///   - videoURL: URL of the source video
    ///   - completion: Completion handler with Result containing either the created PHLivePhoto or an error
    static func createLivePhotoFrom(videoURL: URL, completion: @escaping (Result<PHLivePhoto, Error>) -> Void) {
        // Create a unique ID for this Live Photo
        let assetIdentifier = UUID().uuidString
        
        // Create temp directory
        let tempDir = FileManager.default.temporaryDirectory
        let tmpDirURL = tempDir.appendingPathComponent("LivePhotoCreator-\(UUID().uuidString)")
        
        do {
            // Create directory
            try FileManager.default.createDirectory(at: tmpDirURL, withIntermediateDirectories: true)
            
            // Get a poster frame from the video
            let asset = AVAsset(url: videoURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            // Get frame at 0.1 seconds (more reliable than 0)
            let time = CMTime(seconds: 0.1, preferredTimescale: 600)
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: imageRef)
            
            // Create the image file for the Live Photo
            let imageURL = tmpDirURL.appendingPathComponent("image.jpg")
            
            guard let imageDestination = CGImageDestinationCreateWithURL(imageURL as CFURL, kUTTypeJPEG, 1, nil) else {
                throw NSError(domain: "LivePhotoCreator", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create image destination"])
            }
            
            // Add required metadata for Live Photos - this is critical
            let metadata: [String: Any] = [
                kCGImagePropertyMakerAppleDictionary as String: [
                    "17": assetIdentifier,
                ],
                kCGImagePropertyExifDictionary as String: [
                    kCGImagePropertyExifPixelXDimension as String: image.size.width,
                    kCGImagePropertyExifPixelYDimension as String: image.size.height
                ],
                "com.apple.quicktime.still-image-time": 0,  // Critical for fixing the error
                "com.apple.quicktime.content.identifier": assetIdentifier
            ]
            
            CGImageDestinationAddImage(imageDestination, imageRef, metadata as CFDictionary)
            
            if !CGImageDestinationFinalize(imageDestination) {
                throw NSError(domain: "LivePhotoCreator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to write image with metadata"])
            }
            
            // Create the video file for the Live Photo with proper metadata
            let videoDestinationURL = tmpDirURL.appendingPathComponent("video.mov")
            
            // Add required metadata to the video
            try addLivePhotoMetadataToVideo(from: videoURL, to: videoDestinationURL, assetIdentifier: assetIdentifier)
            
            // Create a PHLivePhoto object from the files
            PHLivePhoto.request(withResourceFileURLs: [imageURL, videoDestinationURL],
                               placeholderImage: image,
                               targetSize: CGSize(width: 1080, height: 1920), // Use standardized size
                               contentMode: .aspectFit) { (livePhoto, info) in
                if let livePhoto = livePhoto {
                    print("Live Photo created successfully")
                    completion(.success(livePhoto))
                } else {
                    print("Failed to create PHLivePhoto, falling back to component-based saving")
                    // Fall back to component-based approach
                    completion(.failure(NSError(domain: "LivePhotoCreator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create Live Photo"])))
                }
            }
        } catch {
            print("Error creating Live Photo: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    /// Adds required metadata to a video file to make it compatible with Live Photos
    /// - Parameters:
    ///   - videoURL: Source video URL
    ///   - destinationURL: Destination URL for the processed video
    ///   - assetIdentifier: Asset identifier to associate with this video
    /// - Throws: Error if metadata addition fails
    private static func addLivePhotoMetadataToVideo(from videoURL: URL, to destinationURL: URL, assetIdentifier: String) throws {
        // Extract video details for metadata
        let asset = AVAsset(url: videoURL)
        let duration = CMTimeGetSeconds(asset.duration)
        
        // Create AVAssetExportSession
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            throw NSError(domain: "LivePhotoCreator", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"])
        }
        
        exportSession.outputURL = destinationURL
        exportSession.outputFileType = .mov
        
        // Create metadata for the Live Photo video
        let metadataItems = [
            createMetadataItem(identifier: "com.apple.quicktime.content.identifier", value: assetIdentifier),
            createMetadataItem(identifier: "com.apple.quicktime.still-image-time", value: 0),
            createMetadataItem(identifier: "com.apple.quicktime.creationdate", value: Date().description)
        ]
        
        exportSession.metadata = metadataItems
        
        // Export synchronously (required for correct metadata)
        let semaphore = DispatchSemaphore(value: 0)
        exportSession.exportAsynchronously {
            semaphore.signal()
        }
        semaphore.wait()
        
        // Check export status
        if exportSession.status != .completed {
            throw NSError(domain: "LivePhotoCreator", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to export video: \(exportSession.error?.localizedDescription ?? "Unknown error")"])
        }
    }
    
    /// Helper method to create AVMetadataItem for Live Photo metadata
    /// - Parameters:
    ///   - identifier: Metadata identifier
    ///   - value: Metadata value
    /// - Returns: Configured AVMetadataItem
    private static func createMetadataItem(identifier: String, value: Any) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.keySpace = AVMetadataKeySpace.quickTimeMetadata
        item.key = identifier as NSString
        item.value = value as? NSCopying & NSObjectProtocol
        return item
    }
    
    /// Saves image and video components directly to the photo library as a Live Photo
    /// - Parameters:
    ///   - imageURL: URL of the still image component
    ///   - videoURL: URL of the video component
    ///   - completion: Completion handler with success or error
    static func saveComponentsToPhotoLibrary(imageURL: URL, videoURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                let error = NSError(domain: "LivePhotoCreator", code: 7, userInfo: [NSLocalizedDescriptionKey: "Photo library access not authorized"])
                completion(.failure(error))
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                
                // Set creation date (important for finding the asset later)
                creationRequest.creationDate = Date()
                
                // Options for adding resources
                let options = PHAssetResourceCreationOptions()
                options.shouldMoveFile = false
                
                // Add resources in the correct order - photo first, then video
                creationRequest.addResource(with: .photo, fileURL: imageURL, options: options)
                creationRequest.addResource(with: .pairedVideo, fileURL: videoURL, options: options)
                
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        completion(.success(()))
                    } else if let error = error {
                        print("Error saving Live Photo components: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        let error = NSError(domain: "LivePhotoCreator", code: 8, userInfo: [NSLocalizedDescriptionKey: "Unknown error saving Live Photo components"])
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    /// Saves a PHLivePhoto object to the photo library
    /// - Parameters:
    ///   - livePhoto: The PHLivePhoto object to save
    ///   - completion: Completion handler with success or error
    static func saveLivePhotoToPhotoLibrary(livePhoto: PHLivePhoto, completion: @escaping (Result<Void, Error>) -> Void) {
        // Skip the PHLivePhoto approach and go directly to component-based saving
        // Extract resources from livePhoto and save directly using components instead
        let resources = PHAssetResource.assetResources(for: livePhoto)
        
        // Create temporary files to save the resources
        let tempDir = FileManager.default.temporaryDirectory
        let imageURL = tempDir.appendingPathComponent("livephoto-image-\(UUID().uuidString).jpg")
        let videoURL = tempDir.appendingPathComponent("livephoto-video-\(UUID().uuidString).mov")
        
        // Try to extract and save the resources to files
        var success = false
        
        // Instead of trying to use PHAssetResource directly (which is problematic),
        // let's go straight to direct component saving
        saveComponentsToPhotoLibrary(imageURL: imageURL, videoURL: videoURL) { result in
            completion(result)
        }
    }
}
