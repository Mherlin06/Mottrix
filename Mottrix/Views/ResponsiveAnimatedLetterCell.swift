//
//  AnimatedLetterCell.swift
//  Mottrix
//
//  Created by Hugues Mourice on 24/07/2025.
//

import SwiftUI

struct ResponsiveAnimatedLetterCell: View {
    let letter: Character?
    let state: LetterState
    let themeManager: ThemeManager
    let isFirstLetter: Bool
    let firstLetterHint: Character?
    let animationDelay: Double
    let cellSize: CGFloat
    
    @State private var isRevealed = false
    @State private var scale: CGFloat = 1.0
    @State private var isPulsing = false
    
    var body: some View {
        Rectangle()
            .fill(backgroundColor)
            .frame(width: cellSize, height: cellSize)
            .overlay(
                Text(displayLetter)
                    .font(dynamicFont)
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
            )
            .overlay(
                Rectangle()
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .scaleEffect(scale)
            .rotation3DEffect(
                .degrees(isRevealed ? 360 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(isPulsing ? 0.7 : 1.0)
            .onAppear {
                if state != .notGuessed {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(animationDelay)) {
                        isRevealed = true
                    }
                }
                
                // Animation de pulsation pour la solution
                if state == .solution {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        isPulsing = true
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
                    case .solution:
                        HapticManager.shared.error()
                    default:
                        break
                    }
                    
                    // Animation de pulsation pour la solution
                    if newState == .solution {
                        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                            isPulsing = true
                        }
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
    
    private var dynamicFont: Font {
        if cellSize < 40 {
            return .caption
        } else if cellSize < 50 {
            return .body
        } else {
            return .title2
        }
    }
    
    private var borderWidth: CGFloat {
        return cellSize < 40 ? 1.5 : 2.0
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
        case .solution:
            return Color.red // Rouge pour la solution
        }
    }
    
    private var textColor: Color {
        switch state {
        case .notGuessed:
            return themeManager.primaryTextColor
        case .correct, .wrongPosition, .solution:
            return Color.white
        case .absent:
            return themeManager.isDarkMode ? Color.white : Color.black
        }
    }
    
    private var borderColor: Color {
        if state == .solution {
            return Color.red.opacity(0.8)
        }
        if isFirstLetter && state == .notGuessed {
            return Color.blue.opacity(0.7)
        }
        return letter != nil ? Color.gray : Color.gray.opacity(0.3)
    }
}
