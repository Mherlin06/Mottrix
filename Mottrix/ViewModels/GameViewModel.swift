//
//  GameViewModel.swift
//  Mottrix
//
//  Created by Hugues Mourice on 23/07/2025.
//

import Foundation

class GameViewModel: ObservableObject {
    @Published var game: Game
    @Published var currentInput: String = ""
    @Published var gameStatus: GameStatus = .playing
    @Published var errorMessage: String = ""
    
    enum GameStatus {
        case playing
        case won
        case lost
    }
    
    init(difficulty: Int = 5) {
        guard let word = DictionaryManager.shared.getRandomWord(length: difficulty) else {
            self.game = Game(targetWord: "MAISON")
            return
        }
        self.game = Game(targetWord: word)
        print("Mot à deviner: \(game.targetWord)")
    }
    
    func submitGuess() {
        // Le mot complet = première lettre + input utilisateur
        let completeWord = getCompleteCurrentWord()
        
        // Validations
        guard completeWord.count == game.difficulty else {
            showError("Le mot doit faire \(game.difficulty) lettres")
            return
        }
        
        guard DictionaryManager.shared.isValidWord(completeWord) else {
            showError("Mot non reconnu")
            return
        }
        
        guard game.currentGuessIndex < game.maxAttempts else {
            return
        }
        
        // Validation du mot contre le mot cible
        let letterStates = GameLogic.validateGuess(completeWord, against: game.targetWord)
        let validatedGuess = GameLogic.createGuess(from: completeWord, states: letterStates)
        
        // Mettre à jour le jeu
        game.guesses[game.currentGuessIndex] = validatedGuess
        
        // Vérifier victoire
        if GameLogic.isGameWon(validatedGuess) {
            gameStatus = .won
        } else {
            game.currentGuessIndex += 1
            
            // Vérifier défaite
            if game.currentGuessIndex >= game.maxAttempts {
                gameStatus = .lost
            }
        }
        
        // Reset input
        currentInput = ""
        clearError()
    }
    
    func startNewGame(difficulty: Int? = nil) {
        let newDifficulty = difficulty ?? game.difficulty
        
        guard let word = DictionaryManager.shared.getRandomWord(length: newDifficulty) else {
            return
        }
        
        game = Game(targetWord: word)
        gameStatus = .playing
        currentInput = ""
        clearError()
        
        print("Nouveau mot à deviner: \(game.targetWord)")
    }
    
    func addLetter(_ letter: Character) {
        // Permettre de saisir jusqu'à difficulty-1 lettres (car première lettre est donnée)
        let maxInputLength = game.difficulty - 1
        
        guard currentInput.count < maxInputLength,
              gameStatus == .playing else { return }
        
        currentInput += String(letter).uppercased()
        clearError()
    }
    
    func deleteLetter() {
        guard !currentInput.isEmpty else { return }
        currentInput.removeLast()
        clearError()
    }
    
    // Fonction pour obtenir le mot complet avec la première lettre
    func getCompleteCurrentWord() -> String {
        guard let firstLetter = game.targetWord.first else { return currentInput }
        return String(firstLetter) + currentInput
    }
    
    // Fonction pour obtenir la première lettre du mot à deviner
    func getFirstLetter() -> Character? {
        return game.targetWord.first
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        
        // Faire disparaître l'erreur après 3 secondes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.clearError()
        }
    }
    
    private func clearError() {
        errorMessage = ""
    }
}
