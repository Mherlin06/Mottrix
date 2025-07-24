//
//  AnimatedLetterCell.swift
//  Mottrix
//
//  Created by Hugues Mourice on 24/07/2025.
//

import SwiftUI

struct AnimatedLetterCell: View {
    let letter: Character?
    let state: LetterState
    let themeManager: ThemeManager
    let isFirstLetter: Bool
    let firstLetterHint: Character?
    let animationDelay: Double
    
    @State private var isRevealed = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Rectangle()
            .fill(backgroundColor)
            .frame(width: 50, height: 50)
            .overlay(
                Text(displayLetter)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
            )
            .overlay(
                Rectangle()
                    .stroke(borderColor, lineWidth: 2)
            )
            .scaleEffect(scale)
            .rotation3DEffect(
                .degrees(isRevealed ? 360 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .onAppear {
                if state != .notGuessed {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(animationDelay)) {
                        isRevealed = true
                    }
                }
            }
            .onChange(of: state) { newState in
                if newState != .notGuessed {
                    withAnimation(.spring(response: 0.3)) {
                        scale = 1.1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3)) {
                            scale = 1.0
                        }
                    }
                    
                    // Haptic feedback selon l'état
                    switch newState {
                    case .correct:
                        HapticManager.shared.success()
                    case .wrongPosition:
                        HapticManager.shared.mediumImpact()
                    case .absent:
                        HapticManager.shared.lightImpact()
                    default:
                        break
                    }
                }
            }
    }
    
    private var displayLetter: String {
        if let letter = letter {
            return String(letter)
        }
        return ""
    }
    
    private var backgroundColor: Color {
        switch state {
        case .notGuessed:
            return themeManager.isDarkMode ? Color.gray.opacity(0.2) : Color.white
        case .correct:
            return Color.green
        case .wrongPosition:
            return Color.orange
        case .absent:
            return Color.gray.opacity(0.5)
        }
    }
    
    private var textColor: Color {
        switch state {
        case .notGuessed:
            return themeManager.primaryTextColor
        case .correct, .wrongPosition:
            return Color.white
        case .absent:
            return themeManager.isDarkMode ? Color.white : Color.black
        }
    }
    
    private var borderColor: Color {
        if isFirstLetter && state == .notGuessed {
            return Color.blue.opacity(0.7) // Bordure bleue pour indiquer l'indice
        }
        return letter != nil ? Color.gray : Color.gray.opacity(0.3)
    }
}

