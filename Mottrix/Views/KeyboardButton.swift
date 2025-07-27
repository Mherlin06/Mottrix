//
//  KeyboardButton.swift
//  Mottrix
//
//  Created by Hugues Mourice on 24/07/2025.
//

import SwiftUI

struct KeyboardButton: View {
    let letter: String
    let letterState: LetterState
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
        switch letterState {
        case .correct:
            return Color.green
        case .wrongPosition:
            return Color.orange
        case .absent:
            return Color.gray.opacity(0.6)
        case .notGuessed:
            if themeManager.isDarkMode {
                return Color.white.opacity(0.15)
            } else {
                return Color.black.opacity(0.08)
            }
        default:
            if themeManager.isDarkMode {
                return Color.white.opacity(0.15)
            } else {
                return Color.black.opacity(0.08)
            }
        }
    }
    
    private var keyboardButtonTextColor: Color {
        switch letterState {
        case .correct, .wrongPosition, .absent:
            return Color.white
        case .notGuessed:
            if themeManager.isDarkMode {
                return Color.white
            } else {
                return Color.black
            }
        default:
            if themeManager.isDarkMode {
                return Color.white
            } else {
                return Color.black
            }
        }
    }
    
    private var keyboardButtonBorderColor: Color {
        switch letterState {
        case .correct:
            return Color.green.opacity(0.8)
        case .wrongPosition:
            return Color.orange.opacity(0.8)
        case .absent:
            return Color.gray.opacity(0.8)
        case .notGuessed:
            if themeManager.isDarkMode {
                return Color.white.opacity(0.3)
            } else {
                return Color.black.opacity(0.2)
            }
        default:
            if themeManager.isDarkMode {
                return Color.white.opacity(0.3)
            } else {
                return Color.black.opacity(0.2)
            }
        }
    }
}
