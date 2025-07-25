//
//  KeyboardButton.swift
//  Mottrix
//
//  Created by Hugues Mourice on 24/07/2025.
//

import SwiftUI

struct KeyboardButton: View {
    let letter: String
    let themeManager: ThemeManager
    let action: () -> Void
    
    var body: some View {
        Button(letter) {
            action()
        }
        .font(.caption)
        .fontWeight(.medium)
        .frame(width: 32, height: 45)
        .background(keyboardButtonBackground)
        .foregroundColor(keyboardButtonTextColor)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(keyboardButtonBorderColor, lineWidth: 1)
        )
    }
    
    private var keyboardButtonBackground: Color {
        if themeManager.isDarkMode {
            return Color.white.opacity(0.15) // Plus clair en mode sombre
        } else {
            return Color.black.opacity(0.08) // Plus sombre en mode clair
        }
    }
    
    private var keyboardButtonTextColor: Color {
        if themeManager.isDarkMode {
            return Color.white // Blanc en mode sombre
        } else {
            return Color.black // Noir en mode clair
        }
    }
    
    private var keyboardButtonBorderColor: Color {
        if themeManager.isDarkMode {
            return Color.white.opacity(0.3)
        } else {
            return Color.black.opacity(0.2)
        }
    }
}
