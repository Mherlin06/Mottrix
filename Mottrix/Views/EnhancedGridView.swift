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
    let showVictoryWord: Bool
    let shouldShowFirstLetterHint: Bool
    let firstLetterUsed: Bool
    
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
                                firstLetterHint: shouldShowHintAt(row: row, col: col) ? firstLetter : nil,
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
    
    private func shouldShowHintAt(row: Int, col: Int) -> Bool {
        // Afficher l'indice uniquement sur la ligne courante, première colonne, si l'indice est utilisé
        return row == game.currentGuessIndex && col == 0 && shouldShowFirstLetterHint && firstLetterUsed
    }
    
    private func letterAt(row: Int, col: Int) -> Character? {
        // Si c'est la ligne actuelle et qu'on est en train de taper
        if row == game.currentGuessIndex && !showSolutionWord && !showVictoryWord {
            if col == 0 {
                // Première colonne : afficher l'indice si utilisé, sinon la première lettre saisie
                if firstLetterUsed {
                    return firstLetter
                } else if !currentInput.isEmpty {
                    return currentInput.first
                }
                return nil
            }
            
            // Autres colonnes : afficher l'input selon si on utilise l'indice ou non
            let startIndex = firstLetterUsed ? 1 : 1
            let inputIndex = col - startIndex
            let displayInput = firstLetterUsed ? currentInput : String(currentInput.dropFirst())
            
            if inputIndex >= 0 && inputIndex < displayInput.count {
                let stringIndex = displayInput.index(displayInput.startIndex, offsetBy: inputIndex)
                return displayInput[stringIndex]
            }
            return nil
        }
        
        // Afficher les lettres des tentatives précédentes ou solution/victoire
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
        
        // Vérifier si c'est la ligne de victoire
        if isVictoryRow(row: row) {
            let guess = game.guesses[row]
            guard col < guess.letters.count else { return .notGuessed }
            return guess.letters[col].state
        }
        
        // Si c'est la ligne actuelle, pas encore d'état sauf pour l'indice
        if row == game.currentGuessIndex && !showSolutionWord && !showVictoryWord {
            // Première colonne avec indice affiché
            if col == 0 && shouldShowHintAt(row: row, col: col) {
                return .correct // L'indice est affiché en vert
            }
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
    
    private func isVictoryRow(row: Int) -> Bool {
        guard showVictoryWord else { return false }
        let guess = game.guesses[row]
        return !guess.letters.isEmpty && guess.letters.first?.state == .victory
    }
}
