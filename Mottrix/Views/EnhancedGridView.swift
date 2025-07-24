//
//  EnhancedGridView.swift
//  Mottrix
//
//  Created by Hugues Mourice on 24/07/2025.
//

import SwiftUI

struct EnhancedGridView: View {
    let game: Game
    let currentInput: String
    let themeManager: ThemeManager
    let firstLetter: Character?
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<game.maxAttempts, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<game.difficulty, id: \.self) { col in
                        AnimatedLetterCell(
                            letter: letterAt(row: row, col: col),
                            state: stateAt(row: row, col: col),
                            themeManager: themeManager,
                            isFirstLetter: col == 0,
                            firstLetterHint: firstLetter,
                            animationDelay: Double(col) * 0.1
                        )
                    }
                }
            }
        }
    }
    
    private func letterAt(row: Int, col: Int) -> Character? {
        // Première colonne : toujours afficher la première lettre comme indice
        if col == 0 {
            return firstLetter
        }
        
        // Si c'est la ligne actuelle et qu'on est en train de taper
        if row == game.currentGuessIndex {
            let inputIndex = col - 1 // -1 car première lettre prise par l'indice
            if inputIndex < currentInput.count {
                let stringIndex = currentInput.index(currentInput.startIndex, offsetBy: inputIndex)
                return currentInput[stringIndex]
            }
            return nil
        }
        
        // Sinon, afficher les lettres des tentatives précédentes
        let guess = game.guesses[row]
        guard col < guess.letters.count else { return nil }
        return guess.letters[col].character
    }
    
    private func stateAt(row: Int, col: Int) -> LetterState {
        // La première lettre est toujours correcte si c'est une ligne complétée
        if col == 0 && row < game.currentGuessIndex {
            return .correct
        }
        
        // Si c'est la ligne actuelle, pas encore d'état
        if row == game.currentGuessIndex {
            return .notGuessed
        }
        
        let guess = game.guesses[row]
        guard col < guess.letters.count else { return .notGuessed }
        return guess.letters[col].state
    }
}
