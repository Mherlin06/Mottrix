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
    @Published var showSolutionWord: Bool = false
    
    enum GameStatus {
        case playing
        case won
        case lost
        case lostByTimeout // Nouveau statut pour défaite par timeout
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
        let completeWord = getCompleteCurrentWord()
        
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
        
        let letterStates = GameLogic.validateGuess(completeWord, against: game.targetWord)
        let validatedGuess = GameLogic.createGuess(from: completeWord, states: letterStates)
        
        game.guesses[game.currentGuessIndex] = validatedGuess
        
        if GameLogic.isGameWon(validatedGuess) {
            gameStatus = .won
        } else {
            game.currentGuessIndex += 1
            
            if game.currentGuessIndex >= game.maxAttempts {
                gameStatus = .lost
                showSolutionWord = true
            }
        }
        
        currentInput = ""
        clearError()
    }
    
    // Nouvelle fonction pour gérer la défaite par timeout
    func handleTimeExpired() {
        guard gameStatus == .playing else { return }
        
        gameStatus = .lostByTimeout
        showSolutionWord = true
        
        // Afficher le mot solution sur la ligne suivante disponible
        displaySolutionWord()
    }
    
    private func displaySolutionWord() {
        let solutionLineIndex = min(game.currentGuessIndex, game.maxAttempts - 1)
        let solutionGuess = createSolutionGuess()
        game.guesses[solutionLineIndex] = solutionGuess
    }
    
    private func createSolutionGuess() -> Guess {
        var guess = Guess(wordLength: game.targetWord.count)
        
        for char in game.targetWord {
            let gameLetter = GameLetter(character: char, state: .solution) // Nouvel état pour la solution
            guess.letters.append(gameLetter)
        }
        
        return guess
    }
    
    func startNewGame(difficulty: Int? = nil) {
        let newDifficulty = difficulty ?? game.difficulty
        
        guard let word = DictionaryManager.shared.getRandomWord(length: newDifficulty) else {
            return
        }
        
        game = Game(targetWord: word)
        gameStatus = .playing
        currentInput = ""
        showSolutionWord = false
        clearError()
        
        print("Nouveau mot à deviner: \(game.targetWord)")
    }
    
    func addLetter(_ letter: Character) {
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
    
    func getCompleteCurrentWord() -> String {
        guard let firstLetter = game.targetWord.first else { return currentInput }
        return String(firstLetter) + currentInput
    }
    
    func getFirstLetter() -> Character? {
        return game.targetWord.first
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.clearError()
        }
    }
    
    private func clearError() {
        errorMessage = ""
    }
}
