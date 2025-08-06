//
//  SpeedOptionComponent.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

struct SpeedOptionComponent: View {
    let speed: Double
    let title: String
    let description: String
    let bestFor: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                speedIndicator
                contentSection
                Spacer()
                if isSelected { selectionIndicator }
            }
            .padding()
            .background(isSelected ? .purple.opacity(0.1) : .gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .purple : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var speedIndicator: some View {
        VStack(spacing: 4) {
            Text("\(speed, specifier: "%.1f")×")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .primary)
            
            Circle()
                .fill(isSelected ? .white.opacity(0.3) : .gray.opacity(0.3))
                .frame(width: 8, height: 8)
        }
        .frame(width: 60)
        .padding(.vertical, 16)
        .background(
            isSelected 
            ? LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom)
            : LinearGradient(colors: [.gray.opacity(0.1), .gray.opacity(0.05)], startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Best for: \(bestFor)")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
    }
    
    private var selectionIndicator: some View {
        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.purple)
            .font(.title2)
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .font(.subheadline)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}