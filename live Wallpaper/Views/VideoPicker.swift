import SwiftUI
import UIKit
import PhotosUI

/// UIViewControllerRepresentable wrapper for UIImagePickerController
/// Provides a native video picker interface for selecting videos
struct VideoPicker: UIViewControllerRepresentable {
    /// Binding to store the URL of the selected video
    @Binding var videoURL: URL?
    /// Environment variable to dismiss the picker when selection is complete
    @Environment(\.presentationMode) private var presentationMode
    
    /// Creates a coordinator to handle picker delegate methods
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// Creates and configures the UIImagePickerController
    /// - Parameter context: The context in which the picker is created
    /// - Returns: A configured UIImagePickerController for video selection
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        // Restrict to only show video media types
        picker.mediaTypes = ["public.movie"]
        picker.delegate = context.coordinator
        return picker
    }
    
    /// Updates the picker controller if needed (not used in this implementation)
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed
    }
    
    /// Coordinator class to handle UIImagePickerController delegate methods
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        /// Handles picker cancellation
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        /// Handles video selection
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let url = info[.mediaURL] as? URL {
                parent.videoURL = url
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}