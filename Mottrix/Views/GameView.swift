//
//  GameView.swift
//  Mottrix
//
//  Created by Hugues Mourice on 23/07/2025.
//


import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel(difficulty: 5)
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("MOTTRIX")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            // Mot cible (pour debug - à supprimer plus tard)
            Text("Mot à deviner: \(viewModel.game.targetWord)")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Grille de jeu
            GridView(game: viewModel.game)
            
            // Message d'erreur
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            // Input actuel
            HStack {
                Text("Saisie: ")
                Text(viewModel.currentInput)
                    .fontWeight(.bold)
                    .frame(minWidth: 100, alignment: .leading)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Clavier simple
            SimpleKeyboard(viewModel: viewModel)
            
            // Status du jeu
            GameStatusView(viewModel: viewModel)
            
            Spacer()
        }
        .padding()
    }
}

struct GridView: View {
    let game: Game
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<game.maxAttempts, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<game.difficulty, id: \.self) { col in
                        LetterCell(
                            letter: letterAt(row: row, col: col),
                            state: stateAt(row: row, col: col)
                        )
                    }
                }
            }
        }
    }
    
    private func letterAt(row: Int, col: Int) -> Character? {
        let guess = game.guesses[row]
        guard col < guess.letters.count else { return nil }
        return guess.letters[col].character
    }
    
    private func stateAt(row: Int, col: Int) -> LetterState {
        let guess = game.guesses[row]
        guard col < guess.letters.count else { return .notGuessed }
        return guess.letters[col].state
    }
}

struct LetterCell: View {
    let letter: Character?
    let state: LetterState
    
    var body: some View {
        Rectangle()
            .fill(backgroundColor)
            .frame(width: 50, height: 50)
            .overlay(
                Text(letter.map(String.init) ?? "")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
            )
            .overlay(
                Rectangle()
                    .stroke(borderColor, lineWidth: 2)
            )
    }
    
    private var backgroundColor: Color {
        switch state {
        case .notGuessed:
            return Color.white
        case .correct:
            return Color.green
        case .wrongPosition:
            return Color.orange
        case .absent:
            return Color.gray.opacity(0.3)
        }
    }
    
    private var textColor: Color {
        switch state {
        case .notGuessed:
            return Color.black
        case .correct, .wrongPosition:
            return Color.white
        case .absent:
            return Color.black
        }
    }
    
    private var borderColor: Color {
        letter != nil ? Color.gray : Color.gray.opacity(0.3)
    }
}

struct SimpleKeyboard: View {
    @ObservedObject var viewModel: GameViewModel
    
    let rows = [
        ["A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["Q", "S", "D", "F", "G", "H", "J", "K", "L", "M"],
        ["W", "X", "C", "V", "B", "N"]
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { letter in
                        Button(letter) {
                            viewModel.addLetter(Character(letter))
                        }
                        .frame(width: 30, height: 40)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }
            
            // Boutons spéciaux
            HStack(spacing: 20) {
                Button("SUPPR") {
                    viewModel.deleteLetter()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
                
                Button("VALIDER") {
                    viewModel.submitGuess()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

struct GameStatusView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            switch viewModel.gameStatus {
            case .playing:
                Text("Tentative \(viewModel.game.currentGuessIndex + 1)/\(viewModel.game.maxAttempts)")
                    .font(.headline)
                    
            case .won:
                Text("🎉 BRAVO! 🎉")
                    .font(.title)
                    .foregroundColor(.green)
                Text("Vous avez trouvé en \(viewModel.game.currentGuessIndex) essai(s)!")
                
            case .lost:
                Text("😞 Perdu!")
                    .font(.title)
                    .foregroundColor(.red)
                Text("Le mot était: \(viewModel.game.targetWord)")
            }
            
            if viewModel.gameStatus != .playing {
                Button("Nouvelle partie") {
                    viewModel.startNewGame()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
}

#Preview {
    GameView()
}
