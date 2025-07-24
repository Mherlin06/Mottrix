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
    }
    
    private var keyboardButtonBackground: Color {
        if themeManager.isDarkMode {
            return Color.gray.opacity(0.3)
        } else {
            return Color.gray.opacity(0.1)
        }
    }
    
    private var keyboardButtonTextColor: Color {
        return themeManager.primaryTextColor
    }
}

