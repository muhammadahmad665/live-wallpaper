//
//  live_WallpaperApp.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI
import UIKit
import BackgroundTasks

@main
struct live_WallpaperApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        // Register for background tasks
        setupBackgroundTasks()
    }
    
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
    
    // Simpler approach that works on more iOS versions
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
    
    // Handle the background refresh task if available
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
    
    // Schedule app refresh (only available on iOS 13+)
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
