# Live Wallpaper Creator

A sophisticated iOS application that transforms ordinary videos into stunning Live Photos optimized for use as dynamic wallpapers on iPhone. Built with modern SwiftUI and leveraging advanced iOS frameworks, this app provides a complete workflow from video selection to Live Photo creation with professional-grade processing capabilities.

## Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/d79fdb54-aef5-4e4f-b68f-6e5eee6769b3" width="200" alt="Video Editing Screen">
  <img src="https://github.com/user-attachments/assets/8c49c62f-522a-4c04-a2e2-d1af478d393e" width="200" alt="Wallpaper Photo">
   <img src="https://github.com/user-attachments/assets/1a4666c3-6550-4a9f-a73d-0b67a43d28e7" width="200" alt="Wallpaper Screen">
</p>

## ✨ Features

### Core Functionality
- **📱 Video Selection**: Choose any video from your photo library using native PhotosPicker
- **✂️ Smart Trimming**: Intuitive range slider for precise video segment selection (up to 5 seconds)
- **⚡ Speed Control**: Adjustable playback speed (0.5x to 3x) for optimal motion effects
- **🎬 Real-time Preview**: Live preview of trimmed selection with speed adjustments
- **📐 Aspect Ratio Analysis**: Automatic detection and warnings for non-optimal aspect ratios
- **🔄 Live Photo Conversion**: Professional-grade conversion to Apple's Live Photo format
- **💾 Direct Integration**: Seamless saving to Photos library with proper metadata

### Advanced Processing
- **🎯 Automatic Optimization**: Converts videos to standard Live Photo dimensions (1080×1920)
- **🎵 Audio Preservation**: Maintains audio tracks during processing
- **📊 Quality Control**: Uses highest quality export presets for professional results
- **🔧 Background Processing**: Efficient processing with background task support
- **⚠️ Error Handling**: Comprehensive error handling with user-friendly feedback

### User Experience
- **🎨 Modern UI**: Clean SwiftUI interface with gradient backgrounds and animations
- **📱 Haptic Feedback**: Tactile feedback for all interactions
- **💡 Tips & Guidance**: Built-in tips and best practices for creating effective Live Wallpapers
- **🔄 State Management**: Reactive UI with real-time updates and processing status
- **♿ Accessibility**: Designed with accessibility best practices

## 📋 Requirements

- **iOS**: 15.0+
- **Xcode**: 14.0+
- **Swift**: 5.0+
- **Development Target**: iPhone (iOS)

## 🚀 How It Works

The app implements a sophisticated multi-step pipeline to ensure optimal Live Photo quality:

### 1. **Video Selection & Analysis**
- Import videos using PhotosPicker with support for all common formats
- Automatic video analysis including duration, resolution, and aspect ratio detection
- Real-time aspect ratio warnings for optimal Live Wallpaper compatibility

### 2. **Intelligent Video Processing**
```
Original Video → Duration Adjustment → Speed Optimization → Dimension Scaling → Live Photo Format
```
- **Duration Adjustment**: Trim to optimal 3-5 second segments for Live Photo performance
- **Speed Optimization**: Apply speed multipliers (0.5x-3x) to enhance motion effects
- **Quality Scaling**: Resize to standard Live Photo dimensions (1080×1920) with aspect ratio preservation
- **Frame Rate Optimization**: Convert to optimal frame rates for Live Photo compatibility

### 3. **Live Photo Component Generation**
- **Still Frame Extraction**: Generate high-quality poster frame from video midpoint
- **Metadata Embedding**: Add required QuickTime metadata for Live Photo recognition
- **Asset Identifier Matching**: Ensure proper pairing between image and video components
- **Format Conversion**: Convert to HEIC (image) and MOV (video) formats

### 4. **Photos Library Integration**
- **Permission Handling**: Automatic photo library authorization management
- **Component Saving**: Save paired image and video resources as Live Photo
- **Metadata Preservation**: Maintain creation dates and asset relationships
- **Success Verification**: Confirm successful Live Photo creation

## 📱 Using Live Photos as Wallpapers

After creating your Live Photo:

1. **Navigate to Settings**: Go to **Settings → Wallpaper → Choose New Wallpaper**
2. **Select Photos**: Tap **"All Photos"** or **"Recents"**
3. **Find Your Creation**: Locate your newly created Live Photo (appears as the most recent item)
4. **Set as Wallpaper**: Choose "Set as Lock Screen" or "Set Both"
5. **Activate Motion**: On the Lock Screen, press and hold firmly (3D Touch/Haptic Touch) to see your Live Wallpaper animate

### 💡 Pro Tips for Best Results
- **Portrait Orientation**: Use portrait videos for better phone wallpaper fit
- **Central Action**: Keep important motion in the center of the frame
- **Smooth Motion**: Gradual movements work better than quick, jarring motions
- **Loop-Friendly**: Choose segments that can loop naturally for seamless animation

## 🏗️ Technical Implementation

### Core Technologies
- **SwiftUI**: Modern declarative UI framework for responsive interfaces
- **AVFoundation**: Advanced video processing, trimming, and export capabilities
- **Photos Framework**: Live Photo creation and photo library integration
- **Core Image**: Image processing and metadata handling
- **Combine**: Reactive programming for state management
- **Background Tasks**: Efficient processing with iOS background task management

### Advanced Features
- **Objective-C Bridge**: Custom `LivePhotoUtil` class for complex Live Photo metadata handling
- **Memory Management**: Optimized video processing with efficient memory usage
- **Quality Preservation**: Highest quality export presets with lossless processing
- **Error Recovery**: Comprehensive error handling with graceful degradation
- **Performance Optimization**: Asynchronous processing with main queue UI updates

## 🏛️ Architecture

The application follows a clean **MVVM (Model-View-ViewModel)** architecture with modular components:

### 📁 Project Structure
```
live Wallpaper/
├── 📱 App Entry Point
│   ├── live_WallpaperApp.swift          # Main app entry with background task setup
│   └── ContentView.swift                # Root view coordinator
│
├── 🎬 Views/
│   ├── VideoSelectionView.swift         # Initial video selection interface
│   ├── VideoEditingView.swift           # Video trimming and preview
│   ├── VideoPicker.swift                # Native video picker wrapper
│   └── Components/                      # Reusable UI components
│       ├── VideoProcessingActions.swift # Processing controls
│       ├── VideoTrimmingComponent.swift # Trimming interface
│       ├── SpeedControlComponent.swift  # Speed adjustment
│       ├── VideoPlayerComponent.swift   # Video preview player
│       └── [Additional UI Components]   # Navigation, backgrounds, etc.
│
├── 🧠 ViewModel/
│   └── WallpaperViewModel.swift         # Central state management and coordination
│
├── 🔧 Utils/
│   ├── VideoProcessor.swift             # Swift video processing utilities
│   ├── LivePhotoCreator.swift           # Live Photo creation logic
│   ├── Converter4Video.swift            # Advanced video conversion operations
│   ├── Converter4Image.swift            # Image processing and metadata
│   ├── LivePhotoUtil.h/.m               # Objective-C Live Photo utilities
│   └── [Additional Utilities]           # Extensions and helpers
│
└── 🎨 Resources/
    ├── Assets.xcassets/                 # App icons and color assets
    └── metadata.mov                     # Template metadata for Live Photos
```

### 🔄 Data Flow
```
User Input → WallpaperViewModel → VideoProcessor → LivePhotoUtil → Photos Library
     ↑                ↓                    ↓            ↓
UI Updates ←── State Changes ←── Processing ←── Conversion ←── Results
```

## 🧩 Key Components

### **WallpaperViewModel** 
*Central coordinator implementing reactive state management*
- **Responsibilities**: Video selection, processing coordination, state management
- **Key Features**: Reactive properties with `@Published`, error handling, async operations
- **State Properties**: `selectedVideoURL`, `trimmedVideoURL`, `isProcessing`, `errorMessage`

### **VideoProcessor** 
*High-performance video processing utilities*
- **Core Methods**: `trimAndSpeedUpVideo()`, `convertToLivePhoto()`, `saveAsLivePhoto()`
- **Features**: AVFoundation integration, quality optimization, background processing
- **Error Handling**: Comprehensive error types with descriptive messages

### **LivePhotoUtil** (Objective-C)
*Specialized Live Photo creation with metadata handling*
- **Pipeline**: Duration adjustment → Speed optimization → Dimension scaling → Metadata embedding
- **Metadata Management**: QuickTime metadata, asset identifiers, still image timing
- **Quality Control**: Professional-grade conversion with optimal Live Photo specifications

### **Converter4Video** 
*Advanced video manipulation and format conversion*
- **Operations**: Resizing, rotation, duration adjustment, speed modification
- **Quality**: Highest quality presets with lossless processing
- **Compatibility**: Handles various video formats and orientations

### **Video Editing Components**
*Modular SwiftUI components for video editing interface*
- **VideoTrimmingComponent**: Range slider with precision controls
- **SpeedControlComponent**: Speed adjustment with real-time preview
- **VideoPlayerComponent**: AVKit integration with custom controls
- **VideoProcessingActions**: Processing status and action buttons

## 🎯 Design Patterns

### **MVVM Pattern**
- **Views**: SwiftUI views handling UI presentation
- **ViewModels**: Business logic and state management
- **Models**: Data structures and utilities

### **Delegation Pattern**
- Video picker delegate handling
- AVPlayer observation and control
- Background task coordination

### **Reactive Programming**
- Combine framework integration
- `@Published` properties for state binding
- Automatic UI updates on state changes

### **Modular Architecture**
- Reusable UI components
- Separated concerns
- Easy testing and maintenance

## 🚀 Getting Started

### Prerequisites
- macOS with Xcode 14.0 or later
- iOS 15.0+ target device or simulator
- Apple Developer account (for device testing)

### Installation & Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/muhammadahmad665/live-wallpaper.git
   cd live-wallpaper
   ```

2. **Open in Xcode**
   ```bash
   open "live Wallpaper.xcodeproj"
   ```

3. **Configure Signing**
   - Select your development team in project settings
   - Ensure proper bundle identifier configuration
   - Configure Photo Library usage permissions

4. **Build and Run**
   - Select target device or simulator
   - Build and run the project (`Cmd+R`)

### 📝 Usage Guide

#### Basic Workflow
1. **Launch the app** and tap "Select Video" on the main screen
2. **Choose a video** from your photo library using the native picker
3. **Trim your video** using the range slider (keep it under 5 seconds for optimal results)
4. **Adjust speed** if desired (higher speeds create more dynamic wallpapers)
5. **Preview your selection** using the play button
6. **Create Live Wallpaper** by tapping the main action button
7. **Wait for processing** - the app will automatically save to your Photos library
8. **Set as wallpaper** following the instructions provided

#### Advanced Tips
- **Optimal Duration**: Keep final duration between 1-3 seconds for best battery life
- **Speed Settings**: 1.5x-2x speed often provides the best motion effect
- **Video Quality**: Higher resolution source videos produce better results
- **Portrait Orientation**: Works best for phone wallpapers

## 🔒 Permissions

The app requires the following permissions:

- **Photo Library Access**: Required to read source videos and save Live Photos
- **Background Processing**: Optional, for continued processing when app goes to background

These permissions are automatically requested when needed with clear explanations provided to users.

## 🧪 Testing

### Unit Testing
The project includes comprehensive unit tests for core functionality:
- Video processing operations
- Live Photo creation logic
- Error handling scenarios
- State management validation

### Integration Testing
- End-to-end workflow testing
- Photos library integration
- UI component interaction testing

Run tests using Xcode's test navigator or:
```bash
xcodebuild test -scheme "live Wallpaper" -destination "platform=iOS Simulator,name=iPhone 14"
```

## 🐛 Troubleshooting

### Common Issues

**"Live Photo creation failed"**
- Ensure video is properly formatted (MP4/MOV)
- Check that video duration is reasonable (< 30 seconds original)
- Verify photo library permissions are granted

**"Processing takes too long"**
- Try with shorter source videos
- Ensure device has sufficient storage space
- Close other resource-intensive apps

**"Wallpaper doesn't animate"**
- Verify Live Photo was saved correctly in Photos app
- Ensure you're using "Press and Hold" on lock screen
- Check that Live Photos are enabled in Settings

### Performance Optimization
- Process videos during off-peak device usage
- Close unnecessary background apps before processing
- Use Wi-Fi for better performance during processing

## 🤝 Contributing

We welcome contributions to improve the Live Wallpaper Creator! Here's how you can help:

### Development Setup
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the existing code style and architecture patterns
4. Add tests for new functionality
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Style Guidelines
- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Maintain MVVM architecture patterns
- Include comprehensive documentation
- Write meaningful commit messages

### Areas for Contribution
- Additional video processing features
- UI/UX improvements
- Performance optimizations
- Additional export formats
- Accessibility enhancements
- Localization support

## 📜 Credits & Acknowledgments

This project leverages several key technologies and frameworks:

- **Apple Frameworks**: AVFoundation, Photos, SwiftUI, Core Image
- **iOS Development**: Built using Xcode and Swift
- **Live Photos Technology**: Apple's Live Photo format and APIs
- **UI/UX Design**: Modern iOS design principles and Human Interface Guidelines

Special thanks to the iOS development community for sharing knowledge and best practices that made this project possible.

## 📄 License

This project is available under the **MIT License**, which provides maximum flexibility for both personal and commercial use.

### MIT License Overview
- ✅ **Commercial Use**: Use for commercial projects
- ✅ **Modification**: Modify and adapt the code
- ✅ **Distribution**: Distribute the original or modified code
- ✅ **Private Use**: Use for personal projects
- ✅ **Patent Grant**: Express patent grant from contributors

### Requirements
- **License Notice**: Include the original license and copyright notice
- **Copyright Notice**: Preserve copyright information

### Limitations
- ❌ **Liability**: No warranty or liability provided
- ❌ **Trademark**: No trademark rights granted

```
MIT License

Copyright (c) 2025 Ahmad

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

See the [LICENSE](LICENSE) file for the complete legal text.

---

## 📞 Support & Contact

- **Issues**: Report bugs and feature requests via [GitHub Issues](https://github.com/muhammadahmad665/live-wallpaper/issues)
- **Discussions**: Join community discussions in [GitHub Discussions](https://github.com/muhammadahmad665/live-wallpaper/discussions)
- **Documentation**: Full documentation available in the repository

**Made with ❤️ for the iOS community**
