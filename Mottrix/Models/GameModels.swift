//
//  GameModel.swift
//  Mottrix
//
//  Created by Hugues Mourice on 23/07/2025.
//

import Foundation

// État d'une lettre dans le jeu
enum LetterState {
    case notGuessed
    case correct
    case wrongPosition
    case absent
    case solution  // Pour afficher la solution en rouge
    case victory   // Nouveau : pour afficher le mot gagnant en vert
}

// Une lettre avec son état
struct GameLetter {
    let character: Character
    var state: LetterState = .notGuessed
}

// Une tentative (ligne de la grille)
struct Guess {
    var letters: [GameLetter]
    let wordLength: Int
    
    init(wordLength: Int) {
        self.wordLength = wordLength
        self.letters = []
    }
    
    var isComplete: Bool {
        letters.count == wordLength
    }
    
    var word: String {
        String(letters.map { $0.character })
    }
}

// Le jeu principal
struct Game {
    let targetWord: String
    let difficulty: Int // 5-8 lettres
    var guesses: [Guess]
    var currentGuessIndex: Int = 0
    let maxAttempts: Int = 6
    
    init(targetWord: String) {
        self.targetWord = targetWord.uppercased()
        self.difficulty = targetWord.count
        self.guesses = []
        
        for _ in 0..<maxAttempts {
            self.guesses.append(Guess(wordLength: difficulty))
        }
    }
    
    var isGameWon: Bool {
        guard currentGuessIndex > 0 else { return false }
        return guesses[currentGuessIndex-1].word == targetWord
    }
    
    var isGameOver: Bool {
        currentGuessIndex >= maxAttempts || isGameWon
    }
}
