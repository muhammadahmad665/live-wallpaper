import UIKit
import UniformTypeIdentifiers
import CoreServices
import ImageIO
import Photos

/// Utility class to handle image conversion for Live Photos
/// Handles adding the necessary metadata to images to work as part of a Live Photo pair
@objc class Converter4Image: NSObject {
    /// Key for the asset identifier in the Apple maker notes
    private let kFigAppleMakerNote_AssetIdentifier = "17"
    /// The source image to be processed
    private let image: UIImage

    /// Initialize with a UIImage
    /// - Parameter image: The source image to be processed
    @objc init(image: UIImage) {
        self.image = image
    }

    /// Read the asset identifier from an image's metadata
    /// - Returns: The asset identifier string if found, nil otherwise
    @objc func read() -> String? {
        guard let makerNote = metadata(index: 0)?.object(forKey: kCGImagePropertyMakerAppleDictionary) as? NSDictionary else {
            return nil
        }
        return makerNote.object(forKey: kFigAppleMakerNote_AssetIdentifier) as? String
    }

    /// Write the image to disk with the required Live Photo metadata
    /// - Parameters:
    ///   - dest: The destination file path where the image will be saved
    ///   - assetIdentifier: The asset identifier to associate with this image
    @objc func write(dest: String, assetIdentifier: String) {
        // Use UTType.heic for modern HEIC output
        guard let destURL = URL(fileURLWithPath: dest) as CFURL?,
              let destination = CGImageDestinationCreateWithURL(destURL, UTType.heic.identifier as CFString, 1, nil) else { return }
        defer { CGImageDestinationFinalize(destination) }
        
        for i in 0...0 {
            guard let imageSource = self.imageSource() else { return }
            guard let metadata = self.metadata(index: i)?.mutableCopy() as? NSMutableDictionary else { return }
            
            let makerNote = NSMutableDictionary()
            makerNote.setObject(assetIdentifier, forKey: kFigAppleMakerNote_AssetIdentifier as NSCopying)
            metadata.setObject(makerNote, forKey: kCGImagePropertyMakerAppleDictionary as NSString)
            CGImageDestinationAddImageFromSource(destination, imageSource, i, metadata as CFDictionary)
        }
    }

    /// Extract metadata from the image source at the specified index
    /// - Parameter index: Index of the image in the image source
    /// - Returns: Metadata dictionary if available
    private func metadata(index: Int) -> NSDictionary? {
        return self.imageSource().flatMap {
            CGImageSourceCopyPropertiesAtIndex($0, index, nil) as NSDictionary?
        }
    }

    /// Create an image source from the image data
    /// - Returns: CGImageSource if image data is valid
    private func imageSource() -> CGImageSource? {
        return self.data().flatMap {
            CGImageSourceCreateWithData($0 as CFData, nil)
        }
    }

    /// Get the image data in an appropriate format
    /// - Returns: Image data in HEIC format if available, PNG otherwise
    private func data() -> Data? {
        if #available(iOS 17.0, *) {
            return image.heicData()
        } else {
            return image.pngData()
        }
    }
}