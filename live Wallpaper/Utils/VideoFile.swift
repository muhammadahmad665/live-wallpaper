//
//  VideoFile.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import UniformTypeIdentifiers

/// Transferable implementation for video files
/// Allows SwiftUI's PhotosPicker to handle video selection and transfer
struct VideoFile: Transferable {
    /// URL of the video file
    let url: URL
    
    /// Transfer representation for the VideoFile
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
