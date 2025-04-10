# Live Wallpaper Creator

A powerful iOS app that allows users to transform regular videos into Live Photos that can be used as dynamic wallpapers on iPhone.

## Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/d79fdb54-aef5-4e4f-b68f-6e5eee6769b3" width="100" alt="Video Editing Screen">
  <img src="https://github.com/user-attachments/assets/8c49c62f-522a-4c04-a2e2-d1af478d393e" width="100" alt="Wallpaper Photo">
   <img src="https://github.com/user-attachments/assets/1a4666c3-6550-4a9f-a73d-0b67a43d28e7" width="100" alt="Wallpaper Screen">
</p>

## Features

- **Video Selection**: Choose any video from your photo library
- **Video Trimming**: Trim your video to the perfect 3-5 second clip
- **Live Photo Conversion**: Automatically process your video into Apple's Live Photo format
- **Direct Photos Integration**: Save the Live Photo directly to your Photos library
- **Optimized Format**: Creates Live Photos with the correct metadata, dimensions, and specifications

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+

## How It Works

The app follows a multi-step process to ensure high-quality Live Photos:

1. **Video Selection**: Choose a video from your device's photo library
2. **Video Trimming**: Use the intuitive slider to select the perfect segment (max 5 seconds)
3. **Video Processing**:
   - Adjust video duration to ideal length
   - Convert to required frame rate
   - Optimize dimensions (1080×1920)
   - Extract a still frame for the photo component
   - Add required metadata for Live Photo functionality
4. **Save**: The result is saved to your Photos library as a Live Photo

## Using Live Photos as Wallpapers

After creating your Live Photo:

1. Go to **Settings > Wallpaper > Choose New Wallpaper**
2. Tap on **"All Photos"** or **"Recents"**
3. Find your newly created Live Photo (it will be the most recent)
4. Set it as your Lock Screen
5. Press firmly on the Lock Screen to see your Live Wallpaper animate

## Technical Implementation

The app uses several advanced iOS technologies:

- **AVFoundation**: For video processing (trimming, scaling, frame extraction)
- **Photos Framework**: For Live Photo creation and library access
- **Core Image**: For image processing and format conversion
- **SwiftUI**: For the modern, responsive interface
- **Combine**: For reactive programming and state management

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture:

- **Views**: SwiftUI views for UI components
- **ViewModels**: Coordinate between the UI and data processing
- **Utilities**: Handle complex video and image processing tasks
- **Extensions**: Add functionality to system types

## Key Components

- **WallpaperViewModel**: Central coordinator for video selection and processing
- **VideoProcessor**: Handles video trimming and export
- **LivePhotoUtil**: Handles the complex Live Photo creation process
- **Converter4Video**: Processes video for Live Photo compatibility
- **Converter4Image**: Handles still image component with required metadata

## Credits

This project makes use of Apple's frameworks and APIs for Live Photo creation. 

## License

This project is available under the MIT License, which allows you to use, modify, and distribute the code freely, both for personal and commercial projects. 

The MIT License is one of the most permissive and widely used open-source licenses. It places very limited restrictions on reuse and has high compatibility with other licenses.

Key permissions:
- Commercial use
- Modification
- Distribution
- Private use

The only requirement is preserving the copyright and license notices.

See the [LICENSE](LICENSE) file for the complete legal text.
