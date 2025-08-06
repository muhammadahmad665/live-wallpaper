//
//  ViewBuilderExtensions.swift
//  live Wallpaper
//
//  Created by ahmed on 11/04/2025.
//

import SwiftUI

struct BenefitsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Why Speed Matters")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                BenefitRow(
                    icon: "film",
                    text: "More frames packed into 5 seconds"
                )
                
                BenefitRow(
                    icon: "eye",
                    text: "More noticeable motion on lock screen"
                )
                
                BenefitRow(
                    icon: "sparkles",
                    text: "Creates more engaging Live Wallpapers"
                )
                
                BenefitRow(
                    icon: "battery.100",
                    text: "Still optimized for battery life"
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCardStyle()
    }
}