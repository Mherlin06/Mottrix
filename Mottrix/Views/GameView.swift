//
//  GameView.swift
//  Mottrix
//
//  Created by Hugues Mourice on 23/07/2025.
//


import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel(difficulty: 5)
    @State private var showingDifficultySelector = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header avec bouton difficulté
            HStack {
                Text("MOTTRIX")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Difficulté") {
                    showingDifficultySelector = true
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
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
        .sheet(isPresented: $showingDifficultySelector) {
            DifficultySelectionView(viewModel: viewModel)
        }
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
                Text("Vous avez trouvé en \(viewModel.game.currentGuessIndex + 1) essai(s)!")
                
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

// Vue de sélection de difficulté
struct DifficultySelectionView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Choisissez votre difficulté")
                    .font(.title2)
                    .padding()
                
                ForEach(5...8, id: \.self) { length in
                    DifficultyButton(
                        length: length,
                        wordCount: DictionaryManager.shared.getWordCount(for: length)
                    ) {
                        viewModel.startNewGame(difficulty: length)
                        dismiss()
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Difficulté")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DifficultyButton: View {
    let length: Int
    let wordCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(length) lettres")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(wordCount) mots disponibles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(difficultyLevel)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(difficultyColor.opacity(0.2))
                    .foregroundColor(difficultyColor)
                    .cornerRadius(4)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private var difficultyLevel: String {
        switch length {
        case 5: return "Facile"
        case 6: return "Moyen"
        case 7: return "Difficile"
        case 8: return "Expert"
        default: return "?"
        }
    }
    
    private var difficultyColor: Color {
        switch length {
        case 5: return .green
        case 6: return .blue
        case 7: return .orange
        case 8: return .red
        default: return .gray
        }
    }
}

#Preview("Difficulty") {
    DifficultySelectionView(viewModel: GameViewModel())
}
