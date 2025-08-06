//
//  live_WallpaperApp.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import UIKit
import BackgroundTasks

/**
 The main app structure for Live Wallpaper Creator.
 
 This struct serves as the entry point for the Live Wallpaper Creator app,
 managing the app lifecycle, background processing capabilities, and global
 app configuration. It sets up the root scene and handles system integration.
 
 ## Features
 
 - **Background Task Management**: Handles background processing for video operations
 - **Scene Phase Monitoring**: Responds to app lifecycle changes
 - **Global Styling**: Sets app-wide color scheme and accent colors
 - **Background Fetch**: Provides extended processing time when needed
 
 ## Architecture
 
 The app follows SwiftUI's modern app lifecycle pattern with scene-based
 architecture. It uses background task scheduling to ensure video processing
 operations can complete even when the app transitions to background.
 
 - Important: Requires background processing capabilities in app configuration
 - Note: Background tasks are only available on iOS 13.0 and later
 */
@main
struct live_WallpaperApp: App {
    
    // MARK: - Environment
    
    /**
     Monitors the app's scene phase for lifecycle management.
     
     Used to detect when the app transitions to background state
     and trigger appropriate background processing requests.
     */
    @Environment(\.scenePhase) var scenePhase
    
    // MARK: - Initialization
    
    /**
     Initializes the app and sets up background processing capabilities.
     
     Called once when the app launches to configure background task
     registration and other system integrations.
     */
    init() {
        // Register for background tasks
        setupBackgroundTasks()
    }
    
    // MARK: - Scene Configuration
    
    /**
     The main app scene containing the primary user interface.
     
     Configures the root window group with the ContentView and applies
     global styling preferences. Also monitors scene phase changes to
     handle background processing requirements.
     
     ## Configuration
     
     - **Color Scheme**: Light mode preferred for optimal video preview
     - **Accent Color**: Blue theme consistent with app branding
     - **Background Handling**: Automatic background processing requests
     */
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .accentColor(.blue)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                requestBackgroundProcessingTime()
            }
        }
    }
    
    // MARK: - Background Processing Setup
    
    /**
     Configures background task processing capabilities.
     
     Sets up background fetch intervals and registers background task handlers
     to ensure video processing operations can complete when the app is
     backgrounded during lengthy operations.
     
     ## Configuration
     
     - Sets minimum background fetch interval for optimal processing
     - Registers BGAppRefreshTask handler for iOS 13.0+
     - Uses app bundle identifier for unique task identification
     
     - Important: Requires "Background App Refresh" capability in app settings
     - Note: Background tasks have system-imposed time limits
     */
    private func setupBackgroundTasks() {
        // Set minimum background fetch interval
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        // Register background task if available
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.binarywolf.live-Wallpaper.refresh", 
                                           using: nil) { task in
                self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
        }
    }
    
    /**
     Requests background processing time for completing operations.
     
     This method provides a fallback approach for background processing
     that works across iOS versions. It requests additional execution time
     when the app transitions to background state.
     
     ## Process
     
     1. Begins a background task with expiration handler
     2. Provides 5 seconds of guaranteed processing time
     3. Automatically ends the task to prevent system termination
     
     ## Use Cases
     
     - Completing video processing operations
     - Saving files to photo library
     - Cleaning up temporary resources
     
     - Important: Background time is limited by system policies
     - Note: Always end background tasks to avoid app termination
     */
    private func requestBackgroundProcessingTime() {
        // Request extra time to complete saving operations
        var taskID: UIBackgroundTaskIdentifier = .invalid
        taskID = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(taskID)
            taskID = .invalid
        }
        
        // End the task when we're sure all operations are done
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if taskID != .invalid {
                UIApplication.shared.endBackgroundTask(taskID)
                taskID = .invalid
            }
        }
    }
    
    /**
     Handles background app refresh tasks on iOS 13.0 and later.
     
     This method is called by the system when a scheduled background refresh
     task executes. It provides an opportunity to perform maintenance operations
     and schedule future refresh tasks.
     
     - Parameter task: The BGAppRefreshTask provided by the system
     
     ## Operations
     
     1. Schedules the next background refresh cycle
     2. Sets up task expiration handling
     3. Performs any necessary maintenance
     4. Marks task completion for system tracking
     
     ## Time Limits
     
     Background refresh tasks have strict time limits imposed by the system.
     All operations must complete within the allocated time or be gracefully
     terminated when the expiration handler is called.
     
     - Important: Always call setTaskCompleted() to inform the system
     - Note: Available only on iOS 13.0 and later
     */
    @available(iOS 13.0, *)
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule a new refresh task
        scheduleAppRefresh()
        
        // Create a task assertion to use the background time
        let taskAssertionID = UIBackgroundTaskIdentifier.invalid
        
        // Set up task expiration handler
        task.expirationHandler = {
            // End background task if needed
            if taskAssertionID != .invalid {
                UIApplication.shared.endBackgroundTask(taskAssertionID)
            }
            
            // Mark the task complete
            task.setTaskCompleted(success: false)
        }
        
        // After task is done
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Mark the task complete
            task.setTaskCompleted(success: true)
        }
    }
    
    /**
     Schedules the next background app refresh task.
     
     This method creates and submits a new BGAppRefreshTaskRequest to the
     system scheduler. The task will be executed at system discretion based
     on user behavior and device conditions.
     
     ## Scheduling Parameters
     
     - **Identifier**: Uses app bundle identifier for uniqueness
     - **Earliest Begin Date**: 15 minutes from scheduling time
     - **System Discretion**: Actual execution depends on iOS scheduling algorithms
     
     ## Error Handling
     
     Scheduling can fail for various reasons including:
     - Background App Refresh disabled in settings
     - System resource constraints
     - Invalid task identifiers or parameters
     
     - Important: Only available on iOS 13.0 and later
     - Note: Requires "Background App Refresh" to be enabled by user
     */
    @available(iOS 13.0, *)
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.binarywolf.live-Wallpaper.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}
