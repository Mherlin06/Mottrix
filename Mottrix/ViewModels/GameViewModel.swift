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
            // Fallback si pas de mot trouvé
            self.game = Game(targetWord: "MAISON")
            return
        }
        self.game = Game(targetWord: word)
        print("Mot à deviner: \(game.targetWord)") // Pour debug - à supprimer plus tard
    }
    
    func submitGuess() {
        // Validations
        guard currentInput.count == game.difficulty else {
            showError("Le mot doit faire \(game.difficulty) lettres")
            return
        }
        
        guard DictionaryManager.shared.isValidWord(currentInput) else {
            showError("Mot non reconnu")
            return
        }
        
        guard game.currentGuessIndex < game.maxAttempts else {
            return // Partie terminée
        }
        
        // Validation du mot contre le mot cible
        let letterStates = GameLogic.validateGuess(currentInput, against: game.targetWord)
        let validatedGuess = GameLogic.createGuess(from: currentInput, states: letterStates)
        
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
        
        print("Nouveau mot à deviner: \(game.targetWord)") // Debug
    }
    
    func addLetter(_ letter: Character) {
        guard currentInput.count < game.difficulty,
              gameStatus == .playing else { return }
        
        currentInput += String(letter).uppercased()
        clearError()
    }
    
    func deleteLetter() {
        guard !currentInput.isEmpty else { return }
        currentInput.removeLast()
        clearError()
    }
    
    private func showError(_ message: String) {
        errorMessage = message
    }
    
    private func clearError() {
        errorMessage = ""
    }
}
