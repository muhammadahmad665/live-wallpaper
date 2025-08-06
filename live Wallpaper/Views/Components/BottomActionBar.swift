//
//  BottomActionBar.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

struct BottomActionBar: View {
    @Binding var showVideoPicker: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Divider()
            
            Button("Choose Different Video") {
                showVideoPicker = true
            }
            .font(.subheadline)
            .foregroundColor(.blue)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.blue.opacity(0.1))
            .clipShape(Capsule())
        }
        .padding()
        .background(.regularMaterial)
    }
}