//
//  TipsCallToAction.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

struct TipsCallToAction: View {
    let onStartCreating: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Divider()
            
            Text("Ready to create amazing Live Wallpapers?")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Button("Start Creating") {
                onStartCreating()
            }
            .primaryButtonStyle()
        }
    }
}