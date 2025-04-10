#import "live_Wallpaper-Swift.h"
#import "LivePhotoUtil.h"
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

/**
 * LivePhotoUtil
 * 
 * Utility class for converting regular videos into Apple Live Photos.
 * Handles the complete conversion workflow including video duration adjustment,
 * frame rate conversion, and proper metadata embedding required for Live Photos.
 */
@implementation LivePhotoUtil

/**
 * Convert a standard video file to a Live Photo format and save it to the Photos library
 *
 * @param path Path to the source video file to convert
 * @param complete Completion handler called when the conversion completes
 *        - success: Whether the conversion was successful
 *        - message: Description of any error that occurred
 */
+ (void)convertVideo:(NSString*)path complete:(void(^)(BOOL, NSString*))complete;{
    // Initialize resources for Live Photo creation
    NSURL *metaURL = [NSBundle.mainBundle URLForResource:@"metadata" withExtension:@"mov"];
    CGSize livePhotoSize = CGSizeMake(1080, 1920); // Standard Live Photo size
    CMTime livePhotoDuration = CMTimeMake(550, 600); // ~0.92 seconds - optimal for Live Photos
    NSString *assetIdentifier = NSUUID.UUID.UUIDString; // Generate unique identifier
    
    // Setup temporary file paths
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *durationPath = [documentPath stringByAppendingString:@"/duration.mp4"];
    NSString *acceleratePath = [documentPath stringByAppendingString:@"/accelerate.mp4"];
    NSString *resizePath = [documentPath stringByAppendingString:@"/resize.mp4"];
    
    // Clean up any previous temporary files
    [NSFileManager.defaultManager removeItemAtPath:durationPath error:nil];
    [NSFileManager.defaultManager removeItemAtPath:acceleratePath error:nil];
    [NSFileManager.defaultManager removeItemAtPath:resizePath error:nil];
    NSString *finalPath = resizePath;
    
    // Create converter for video processing
    Converter4Video *converter = [[Converter4Video alloc] initWithPath:finalPath];
    
    // Step 1: Adjust video duration to target length (3 seconds)
    [converter durationVideoAt:path outputPath:durationPath targetDuration:3 completion:^(BOOL success, NSError * error) {
        // Step 2: Adjust playback speed to match Live Photo requirements
        [converter accelerateVideoAt:durationPath to:livePhotoDuration outputPath:acceleratePath completion:^(BOOL success, NSError * error) {
            // Step 3: Resize the video to standard Live Photo dimensions
            [converter resizeVideoAt:acceleratePath outputPath:resizePath outputSize:livePhotoSize completion:^(BOOL success, NSError * error) {
                // Step 4: Generate a still image from the video
                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:finalPath] options:nil];
                AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
                generator.appliesPreferredTrackTransform = YES;
                generator.requestedTimeToleranceAfter = kCMTimeZero;
                generator.requestedTimeToleranceBefore = kCMTimeZero;
                
                // Extract frame at 0.5 seconds (typically a good representative frame)
                NSMutableArray *times = [NSMutableArray array];
                CMTime time = CMTimeMakeWithSeconds(0.5, asset.duration.timescale);
                [times addObject:[NSValue valueWithCMTime:time]];
                
                dispatch_queue_t q = dispatch_queue_create("image", DISPATCH_QUEUE_SERIAL);
                __block int index = 0;
                
                // Generate the image asynchronously
                [generator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
                    if (image) {
                        // Step 5: Save the image and video components with matching assetIdentifier
                        NSString *picturePath = [documentPath stringByAppendingFormat:@"/%@%d.heic", @"live", index, nil];
                        NSString *videoPath = [documentPath stringByAppendingFormat:@"/%@%d.mov", @"live", index, nil];
                        index += 1;
                        
                        // Clean up any previous files
                        [NSFileManager.defaultManager removeItemAtPath:picturePath error:nil];
                        [NSFileManager.defaultManager removeItemAtPath:videoPath error:nil];
                        
                        // Create the still image component with metadata
                        Converter4Image *converter4Image = [[Converter4Image alloc] initWithImage:[UIImage imageWithCGImage:image]];
                        dispatch_async(q, ^{
                            // Write the image with the asset identifier
                            [converter4Image writeWithDest:picturePath assetIdentifier:assetIdentifier];
                            
                            // Write the video with the asset identifier and metadata
                            [converter writeWithDest:videoPath assetIdentifier:assetIdentifier metaURL:metaURL completion:^(BOOL success, NSError * error) {
                                if (!success) {
                                    NSLog(@"merge failed: %@", error);
                                    complete(NO, error.localizedDescription);
                                    return;
                                }
                                
                                // Step 6: Save both components to the Photos library as a Live Photo
                                [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
                                    PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                                    NSURL *photoURL = [NSURL fileURLWithPath:picturePath];
                                    NSURL *pairedVideoURL = [NSURL fileURLWithPath:videoPath];
                                    
                                    // Add both components to the request
                                    [request addResourceWithType:PHAssetResourceTypePhoto fileURL:photoURL options:[PHAssetResourceCreationOptions new]];
                                    [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:pairedVideoURL options:[PHAssetResourceCreationOptions new]];
                                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                                    // Return success/failure on main thread
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        complete(error==nil, error.localizedDescription);
                                    });
                                }];
                            }];
                        });
                    }
                }];
            }];
        }];
    }];
}

@end
