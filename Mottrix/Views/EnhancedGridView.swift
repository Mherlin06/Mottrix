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
        GeometryReader { geometry in
            let availableWidth = geometry.size.width * 0.85 // 85% de la largeur
            let cellSize = calculateCellSize(availableWidth: availableWidth, difficulty: game.difficulty)
            let spacing: CGFloat = 4
            
            VStack(spacing: spacing) {
                ForEach(0..<game.maxAttempts, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<game.difficulty, id: \.self) { col in
                            ResponsiveAnimatedLetterCell(
                                letter: letterAt(row: row, col: col),
                                state: stateAt(row: row, col: col),
                                themeManager: themeManager,
                                isFirstLetter: col == 0,
                                firstLetterHint: firstLetter,
                                animationDelay: Double(col) * 0.1,
                                cellSize: cellSize
                            )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: calculateGridHeight(cellSize: calculateCellSize(availableWidth: UIScreen.main.bounds.width * 0.85, difficulty: game.difficulty)))
    }
    
    private func calculateCellSize(availableWidth: CGFloat, difficulty: Int) -> CGFloat {
        let spacing: CGFloat = 4
        let totalSpacing = spacing * CGFloat(difficulty - 1)
        let availableForCells = availableWidth - totalSpacing
        let minCellSize: CGFloat = 35
        let maxCellSize: CGFloat = 60
        
        let calculatedSize = availableForCells / CGFloat(difficulty)
        return max(minCellSize, min(maxCellSize, calculatedSize))
    }
    
    private func calculateGridHeight(cellSize: CGFloat) -> CGFloat {
        let spacing: CGFloat = 4
        let totalSpacing = spacing * CGFloat(game.maxAttempts - 1)
        return (cellSize * CGFloat(game.maxAttempts)) + totalSpacing
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
