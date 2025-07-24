//
//  EnhancedKeyboard.swift
//  Mottrix
//
//  Created by Hugues Mourice on 24/07/2025.
//

import SwiftUI

struct EnhancedKeyboard: View {
    @ObservedObject var viewModel: GameViewModel
    let themeManager: ThemeManager
    
    let rows = [
        ["A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["Q", "S", "D", "F", "G", "H", "J", "K", "L", "M"],
        ["W", "X", "C", "V", "B", "N"]
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { letter in
                        KeyboardButton(
                            letter: letter,
                            themeManager: themeManager
                        ) {
                            viewModel.addLetter(Character(letter))
                            HapticManager.shared.lightImpact()
                        }
                    }
                }
            }
            
            // Boutons spéciaux
            HStack(spacing: 20) {
                Button("SUPPR") {
                    viewModel.deleteLetter()
                    HapticManager.shared.lightImpact()
                }
                .font(.caption)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(8)
                
                Button("VALIDER") {
                    viewModel.submitGuess()
                    HapticManager.shared.mediumImpact()
                }
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .cornerRadius(8)
            }
        }
    }
}
