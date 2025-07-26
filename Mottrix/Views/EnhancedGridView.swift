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
    let showSolutionWord: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width * 0.85
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
        // Première colonne : toujours afficher la première lettre comme indice (sauf pour la solution)
        if col == 0 && !isSolutionRow(row: row) {
            return firstLetter
        }
        
        // Si c'est la ligne actuelle et qu'on est en train de taper
        if row == game.currentGuessIndex && !showSolutionWord {
            if col == 0 {
                return firstLetter
            }
            
            let inputIndex = col - 1
            if inputIndex < currentInput.count {
                let stringIndex = currentInput.index(currentInput.startIndex, offsetBy: inputIndex)
                return currentInput[stringIndex]
            }
            return nil
        }
        
        // Afficher les lettres des tentatives précédentes
        let guess = game.guesses[row]
        guard col < guess.letters.count else { return nil }
        return guess.letters[col].character
    }
    
    private func stateAt(row: Int, col: Int) -> LetterState {
        // Vérifier si c'est la ligne de solution
        if isSolutionRow(row: row) {
            let guess = game.guesses[row]
            guard col < guess.letters.count else { return .notGuessed }
            return guess.letters[col].state
        }
        
        // La première lettre est toujours correcte si c'est une ligne complétée
        if col == 0 && row < game.currentGuessIndex {
            return .correct
        }
        
        // Si c'est la ligne actuelle, pas encore d'état
        if row == game.currentGuessIndex && !showSolutionWord {
            return .notGuessed
        }
        
        let guess = game.guesses[row]
        guard col < guess.letters.count else { return .notGuessed }
        return guess.letters[col].state
    }
    
    private func isSolutionRow(row: Int) -> Bool {
        guard showSolutionWord else { return false }
        let guess = game.guesses[row]
        return !guess.letters.isEmpty && guess.letters.first?.state == .solution
    }
}
