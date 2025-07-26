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
    @State private var animationId = UUID() // Pour forcer la réinitialisation des animations
    
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
            .id(animationId) // Utiliser l'ID pour forcer la réinitialisation
            .onAppear {
                resetAnimations()
                
                if state != .notGuessed {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(animationDelay)) {
                        isRevealed = true
                    }
                }
                
                startPulsingIfNeeded()
            }
            .onChange(of: state) { newState in
                resetAnimations()
                
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
                    case .correct, .victory:
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
                }
                
                startPulsingIfNeeded()
            }
    }
    
    private func resetAnimations() {
        // Arrêter toutes les animations en cours
        withAnimation(.none) {
            isPulsing = false
            scale = 1.0
        }
        
        // Générer un nouvel ID pour forcer la réinitialisation
        animationId = UUID()
    }
    
    private func startPulsingIfNeeded() {
        // Animation de pulsation uniquement pour la solution (rouge)
        if state == .solution {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isPulsing = true
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
            return Color.red
        case .victory:
            return Color.green.opacity(0.8) // Vert plus vif pour la victoire
        }
    }
    
    private var textColor: Color {
        switch state {
        case .notGuessed:
            return themeManager.primaryTextColor
        case .correct, .wrongPosition, .solution, .victory:
            return Color.white
        case .absent:
            return themeManager.isDarkMode ? Color.white : Color.black
        }
    }
    
    private var borderColor: Color {
        if state == .solution {
            return Color.red.opacity(0.8)
        }
        if state == .victory {
            return Color.green.opacity(0.8)
        }
        if isFirstLetter && state == .notGuessed {
            return Color.blue.opacity(0.7)
        }
        return letter != nil ? Color.gray : Color.gray.opacity(0.3)
    }
}
