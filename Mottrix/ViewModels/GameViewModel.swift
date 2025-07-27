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
    @Published var showVictoryWord: Bool = false
    @Published var firstLetterUsed: Bool = true // Nouvelle propriété pour gérer l'indice
    @Published var keyboardLetterStates: [Character: LetterState] = [:] // États des lettres du clavier
    
    enum GameStatus {
        case playing
        case won
        case lost
        case lostByTimeout
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
        
        // Mettre à jour les états des lettres du clavier
        updateKeyboardStates(for: validatedGuess)
        
        if GameLogic.isGameWon(validatedGuess) {
            gameStatus = .won
            showVictoryWord = true
            displayVictoryWord()
        } else {
            game.currentGuessIndex += 1
            
            if game.currentGuessIndex >= game.maxAttempts {
                gameStatus = .lost
                showSolutionWord = true
                displaySolutionWord()
            } else {
                // Réinitialiser l'indice pour la nouvelle ligne
                firstLetterUsed = true
            }
        }
        
        currentInput = ""
        clearError()
    }
    
    func handleTimeExpired() {
        guard gameStatus == .playing else { return }
        
        gameStatus = .lostByTimeout
        showSolutionWord = true
        displaySolutionWord()
    }
    
    private func displaySolutionWord() {
        let solutionLineIndex = min(game.currentGuessIndex, game.maxAttempts - 1)
        let solutionGuess = createSolutionGuess()
        game.guesses[solutionLineIndex] = solutionGuess
    }
    
    private func displayVictoryWord() {
        // Modifier la ligne gagnante pour l'afficher en vert
        let victoryLineIndex = game.currentGuessIndex
        var victoryGuess = game.guesses[victoryLineIndex]
        
        for i in 0..<victoryGuess.letters.count {
            victoryGuess.letters[i].state = .victory
        }
        
        game.guesses[victoryLineIndex] = victoryGuess
    }
    
    private func createSolutionGuess() -> Guess {
        var guess = Guess(wordLength: game.targetWord.count)
        
        for char in game.targetWord {
            let gameLetter = GameLetter(character: char, state: .solution)
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
        showVictoryWord = false
        firstLetterUsed = true
        keyboardLetterStates = [:]
        clearError()
        
        print("Nouveau mot à deviner: \(game.targetWord)")
    }
    
    func addLetter(_ letter: Character) {
        guard gameStatus == .playing else { return }
        
        let maxInputLength = firstLetterUsed ? game.difficulty - 1 : game.difficulty
        guard currentInput.count < maxInputLength else { return }
        
        // Si on tape la première lettre alors qu'on utilise l'indice, on l'ignore
        if firstLetterUsed && currentInput.isEmpty &&
           String(letter).uppercased() == String(game.targetWord.first!).uppercased() {
            return
        }
        
        // Ajouter la lettre normalement
        currentInput += String(letter).uppercased()
        clearError()
    }
    
    func deleteLetter() {
        if !currentInput.isEmpty {
            // Supprimer la dernière lettre tapée
            currentInput.removeLast()
        } else if firstLetterUsed {
            // Si l'input est vide et qu'on utilise l'indice, supprimer l'indice
            firstLetterUsed = false
        }
        
        clearError()
    }
    
    func getCompleteCurrentWord() -> String {
        if firstLetterUsed {
            guard let firstLetter = game.targetWord.first else { return currentInput }
            return String(firstLetter) + currentInput
        } else {
            return currentInput
        }
    }
    
    func getFirstLetter() -> Character? {
        return game.targetWord.first
    }
    
    func shouldShowFirstLetterHint() -> Bool {
        return firstLetterUsed && gameStatus == .playing
    }
    
    // Fonction pour mettre à jour les états des lettres du clavier
    private func updateKeyboardStates(for guess: Guess) {
        for gameLetter in guess.letters {
            let char = gameLetter.character
            let currentState = keyboardLetterStates[char] ?? .notGuessed
            
            // Ne mettre à jour que si le nouvel état est "meilleur"
            // Priorité: .correct > .wrongPosition > .absent
            switch gameLetter.state {
            case .correct:
                keyboardLetterStates[char] = .correct
            case .wrongPosition:
                if currentState != .correct {
                    keyboardLetterStates[char] = .wrongPosition
                }
            case .absent:
                if currentState == .notGuessed {
                    keyboardLetterStates[char] = .absent
                }
            default:
                break
            }
        }
    }
    
    // Fonction pour obtenir l'état d'une lettre du clavier
    func getKeyboardLetterState(_ letter: Character) -> LetterState {
        return keyboardLetterStates[letter] ?? .notGuessed
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
