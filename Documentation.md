# Live Wallpaper Creator - API Documentation

## Overview

Live Wallpaper Creator is a SwiftUI-based iOS application that enables users to transform their videos into Live Photos suitable for use as dynamic wallpapers. The app provides video selection, trimming, speed adjustment, and Live Photo conversion capabilities.

## Architecture

The app follows the MVVM (Model-View-ViewModel) architectural pattern with SwiftUI and is organized into the following key components:

### Core Components

- **`ContentView`**: Main coordinator view that manages the overall app flow
- **`WallpaperViewModel`**: Central business logic coordinator handling video processing
- **`VideoProcessor`**: Utility class for video manipulation operations
- **`VideoFile`**: Transferable implementation for video file handling

### UI Components

The user interface is built using modular, reusable SwiftUI components:

#### Main Views
- **`VideoSelectionView`**: Initial video selection interface
- **`VideoEditingView`**: Video trimming and preview interface
- **`TipsView`**: Educational content and best practices
- **`SpeedRecommendationView`**: Speed selection guidance

#### Reusable Components
- **`HeroSection`**: Animated app introduction component
- **`FeaturesSection`**: App capabilities overview
- **`CallToActionSection`**: Video selection interface
- **`NavigationMenu`**: App navigation and menu options
- **`AlertComponents`**: Error and success feedback components
- **`TipSectionComponent`**: Individual tip display component

### Utility Classes

- **`VideoProcessor`**: Handles video trimming, speed adjustment, and Live Photo conversion
- **`VideoFile`**: Manages video file transfers and temporary storage
- **`TimeFormatter`**: Time display formatting utilities
- **`LivePhotoCreator`**: Live Photo creation and metadata handling

## Key Features

### Video Processing
- **Smart Trimming**: Precise video segment selection with visual feedback
- **Speed Control**: 1x to 2.5x speed adjustment for dynamic effects  
- **Quality Optimization**: Maintains video quality while optimizing for Live Photos
- **Background Processing**: Continues processing when app is backgrounded

### User Experience
- **Intuitive Interface**: Clean, modern SwiftUI design following iOS guidelines
- **Real-time Preview**: Live video preview during editing
- **Haptic Feedback**: Tactile responses for user actions
- **Error Handling**: Comprehensive error reporting and recovery options

### System Integration
- **PhotosPicker Integration**: Seamless video selection from photo library
- **Background Tasks**: Extended processing time using iOS background capabilities
- **Photo Library Access**: Direct saving to user's photo library
- **Settings Integration**: Direct links to wallpaper settings

## API Reference

### Core Classes

#### WallpaperViewModel
```swift
class WallpaperViewModel: ObservableObject
```
Central view model managing video processing workflow.

**Key Properties:**
- `selectedVideoURL: URL?` - Currently selected video file URL
- `trimmedVideoURL: URL?` - Processed video URL ready for Live Photo conversion
- `startTime: Double` - Trim start time in seconds
- `endTime: Double` - Trim end time in seconds  
- `speedMultiplier: Double` - Video playback speed multiplier
- `isProcessing: Bool` - Processing state indicator
- `errorMessage: String?` - Error information for user display

**Key Methods:**
- `loadVideo(from: PhotosPickerItem)` - Loads selected video from photo library
- `processVideo()` - Processes video with current trim and speed settings
- `saveToPhotoLibrary()` - Saves processed video as Live Photo
- `resetVideo()` - Resets all video-related state

#### VideoProcessor
```swift
class VideoProcessor
```
Static utility class for video processing operations.

**Key Methods:**
- `trimAndSpeedUpVideo(at:from:to:speedMultiplier:completion:)` - Main processing method
- `saveAsLivePhoto(from:completion:)` - Converts video to Live Photo format

### UI Components

#### ContentView  
```swift
struct ContentView: View
```
Main application coordinator managing navigation and global state.

#### VideoSelectionView
```swift
struct VideoSelectionView: View
```
Initial interface for video selection with app introduction.

**Parameters:**
- `onSelectVideo: (PhotosPickerItem) -> Void` - Callback for video selection

#### VideoEditingView
```swift
struct VideoEditingView: View  
```
Video editing interface with trimming and preview capabilities.

**Parameters:**
- `videoURL: URL` - Source video URL
- `startTime: Binding<Double>` - Trim start time binding
- `endTime: Binding<Double>` - Trim end time binding
- `speedMultiplier: Binding<Double>` - Speed adjustment binding
- Various action callbacks for processing and saving

## Usage Examples

### Basic Video Processing
```swift
// Initialize view model
@StateObject private var viewModel = WallpaperViewModel()

// Load video from PhotosPicker
viewModel.loadVideo(from: selectedItem)

// Configure processing parameters
viewModel.startTime = 1.0
viewModel.endTime = 4.0
viewModel.speedMultiplier = 2.0

// Process video
viewModel.processVideo()

// Save as Live Photo
viewModel.saveToPhotoLibrary()
```

### Custom Component Usage
```swift
// Hero section with animation
HeroSection()

// Feature display
TipSectionComponent(
    icon: "timer",
    title: "Perfect Duration", 
    description: "Keep videos between 3-5 seconds for best results.",
    color: .green
)

// Navigation menu
NavigationMenu(showTips: $showTips)
```

## Error Handling

The app provides comprehensive error handling through the `VideoProcessingError` enum:

- `noVideoTrack` - Missing video track in source file
- `exportSessionCreationFailed` - AVFoundation export session failure
- `exportFailed(String)` - Processing operation failure with details
- `livePhotoConversionFailed` - Live Photo format conversion failure

All errors include localized descriptions suitable for user presentation.

## Performance Considerations

### Background Processing
- Uses iOS background task capabilities to complete processing when app is backgrounded
- Automatic cleanup of temporary files to manage storage
- Efficient memory usage during video operations

### Optimization Features  
- Smart caching of processed videos
- Optimal video compression settings for Live Photos
- Minimal UI updates during processing to maintain responsiveness

## Requirements

- **iOS Version**: iOS 18.2+
- **Device**: iPhone (optimized for iPhone form factor)
- **Permissions**: Photo Library access required
- **Storage**: Temporary storage for video processing
- **Background**: Background App Refresh recommended for optimal experience

## Best Practices

### For Developers
1. Always handle video processing on background queues
2. Dispatch UI updates to main queue
3. Implement proper error handling for all video operations
4. Clean up temporary resources after processing
5. Use appropriate haptic feedback for user actions

### For Users
1. Use videos in portrait orientation for best results
2. Keep video segments between 3-5 seconds
3. Higher speed multipliers create more dynamic wallpapers
4. Ensure sufficient storage space for processing
5. Enable Background App Refresh for optimal performance

---

*Generated using Apple's Swift documentation standards*