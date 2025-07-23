//
//  GameLogic.swift
//  Mottrix
//
//  Created by Hugues Mourice on 23/07/2025.
//


import Foundation

struct GameLogic {
    
    /// Compare un mot deviné avec le mot cible et retourne les états des lettres
    static func validateGuess(_ guess: String, against target: String) -> [LetterState] {
        let guessChars = Array(guess.uppercased())
        let targetChars = Array(target.uppercased())
        var result: [LetterState] = Array(repeating: .absent, count: guessChars.count)
        
        // Première passe : marquer les lettres correctes (bonne position)
        var targetCharCount: [Character: Int] = [:]
        for (index, char) in targetChars.enumerated() {
            if guessChars[index] == char {
                result[index] = .correct
            } else {
                targetCharCount[char, default: 0] += 1
            }
        }
        
        // Deuxième passe : marquer les lettres mal placées
        for (index, char) in guessChars.enumerated() {
            if result[index] != .correct { // Si pas déjà marqué comme correct
                if let count = targetCharCount[char], count > 0 {
                    result[index] = .wrongPosition
                    targetCharCount[char] = count - 1
                }
            }
        }
        
        return result
    }
    
    /// Crée un Guess à partir d'une string et de ses états
    static func createGuess(from word: String, states: [LetterState]) -> Guess {
        let chars = Array(word.uppercased())
        var guess = Guess(wordLength: chars.count)
        
        for (index, char) in chars.enumerated() {
            let gameLetter = GameLetter(character: char, state: states[index])
            guess.letters.append(gameLetter)
        }
        
        return guess
    }
    
    /// Vérifie si une partie est gagnée
    static func isGameWon(_ guess: Guess) -> Bool {
        return guess.letters.allSatisfy { $0.state == .correct }
    }
}