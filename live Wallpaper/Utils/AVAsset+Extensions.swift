import AVKit
import UIKit

/// Extensions to AVAsset for Live Photo creation functionality
extension AVAsset {
    /// Counts the number of frames in a video asset
    /// - Parameter exact: If true, performs exact frame counting by reading all frames (slower but more accurate).
    ///   If false, uses an estimation based on duration and frame rate (faster).
    /// - Returns: Total number of frames in the video
    func countFrames(exact: Bool) -> Int {
        var frameCount = 0
        if let videoReader = try? AVAssetReader(asset: self)  {
            if let videoTrack = self.tracks(withMediaType: .video).first {
                frameCount = Int(CMTimeGetSeconds(self.duration) * Float64(videoTrack.nominalFrameRate))
                if exact {
                    frameCount = 0
                    let videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: nil)
                    videoReader.add(videoReaderOutput)
                    videoReader.startReading()
                    while true {
                        guard let _ = videoReaderOutput.copyNextSampleBuffer() else { break }
                        frameCount += 1
                    }
                    videoReader.cancelReading()
                }
            }
        }
        return frameCount
    }
    
    /// Retrieves the "still image time" metadata from the video asset
    /// - Returns: The CMTime at which the still image is set in the metadata, or nil if not found
    func stillImageTime() -> CMTime?  {
        var stillTime: CMTime? = nil
        if let videoReader = try? AVAssetReader(asset: self) {
            if let metadataTrack = self.tracks(withMediaType: .metadata).first {
                let videoReaderOutput = AVAssetReaderTrackOutput(track: metadataTrack, outputSettings: nil)
                videoReader.add(videoReaderOutput)
                videoReader.startReading()
                let keyStillImageTime = "com.apple.quicktime.still-image-time"
                let keySpaceQuickTimeMetadata = "mdta"
                var found = false
                while !found {
                    if let sampleBuffer = videoReaderOutput.copyNextSampleBuffer() {
                        if CMSampleBufferGetNumSamples(sampleBuffer) != 0 {
                            let group = AVTimedMetadataGroup(sampleBuffer: sampleBuffer)
                            for item in group?.items ?? [] {
                                if item.key as? String == keyStillImageTime && item.keySpace!.rawValue == keySpaceQuickTimeMetadata {
                                    stillTime = group?.timeRange.start
                                    found = true
                                    break
                                }
                            }
                        }
                    } else {
                        break
                    }
                }
                videoReader.cancelReading()
            }
        }
        return stillTime
    }
    
    /// Creates a time range for the still image that will be shown in a Live Photo
    /// - Parameters:
    ///   - percent: The percentage position within the video duration (0.0-1.0) for the still image
    ///   - inFrameCount: Optional pre-counted frame count. Will be calculated if not provided.
    /// - Returns: A CMTimeRange containing the time position and duration for the still image
    func makeStillImageTimeRange(percent: Float, inFrameCount: Int = 0) -> CMTimeRange {
        var time = self.duration
        var frameCount = inFrameCount
        if frameCount == 0 {
            frameCount = self.countFrames(exact: true)
        }
        let frameDuration = Int64(Float(time.value) / Float(frameCount))
        time.value = Int64(Float(time.value) * percent)
        return CMTimeRangeMake(start: time, duration: CMTimeMake(value: frameDuration, timescale: time.timescale))
    }
    
    /// Extracts a still image frame from the video at a specified percentage of its duration
    /// - Parameter percent: The percentage position (0.0-1.0) at which to extract the frame
    /// - Returns: A UIImage of the frame, or nil if extraction fails
    func getAssetFrame(percent: Float) -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: self)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceAfter = CMTimeMake(value: 1, timescale: 100)
        imageGenerator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: 100)
        var time = self.duration
        time.value = Int64(Float(time.value) * percent)
        do {
            var actualTime = CMTime.zero
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
            return UIImage(cgImage: imageRef)
        } catch let error as NSError {
            print("Image generation failed: \(error)")
            return nil
        }
    }
}
