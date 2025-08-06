//
//  VideoFile.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import UniformTypeIdentifiers

/**
 A transferable implementation for video files in the Live Wallpaper Creator app.
 
 This struct enables SwiftUI's PhotosPicker to handle video selection and transfer
 operations seamlessly. It conforms to the Transferable protocol to provide
 proper integration with iOS's drag and drop and sharing systems.
 
 ## Features
 
 - **PhotosPicker Integration**: Works directly with SwiftUI's PhotosPicker
 - **File Management**: Handles temporary file copying and URL management
 - **Type Safety**: Uses proper UTType definitions for video content
 - **Error Handling**: Provides proper error handling for file operations
 
 ## Usage
 
 This struct is used internally by PhotosPicker when loading video content:
 
 ```swift
 item.loadTransferable(type: VideoFile.self) { result in
     switch result {
     case .success(let videoFile):
         // Use videoFile.url
     case .failure(let error):
         // Handle error
     }
 }
 ```
 
 - Important: The VideoFile manages temporary file copies automatically
 - Note: Temporary files are created in the system's temporary directory
 */
struct VideoFile: Transferable {
    
    // MARK: - Properties
    
    /**
     URL of the video file.
     
     This URL points to the video file location, which may be a temporary
     copy created during the transfer process. The URL is valid for the
     lifetime of the VideoFile instance.
     */
    let url: URL
    
    // MARK: - Transferable Conformance
    
    /**
     Transfer representation configuration for video files.
     
     This computed property defines how VideoFile instances are transferred
     to and from the system. It handles both importing (from PhotosPicker)
     and exporting (for sharing) scenarios.
     
     ## Import Process
     
     1. Receives a transferred file from PhotosPicker
     2. Creates a unique temporary file location
     3. Copies the file to the temporary location
     4. Returns a VideoFile instance with the copied file URL
     
     ## Export Process
     
     1. Takes the VideoFile's URL
     2. Creates a SentTransferredFile for system sharing
     
     - Important: Import operations create temporary file copies
     - Note: Uses .movie content type for broad video format support
     */
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { videoFile in
            // For exporting - return a SentTransferredFile
            SentTransferredFile(videoFile.url)
        } importing: { received in
            // For importing - copy the file to a temporary location and return a VideoFile
            let copy = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
            try FileManager.default.copyItem(at: received.file, to: copy)
            return VideoFile(url: copy)
        }
    }
}
