//
//  GameStatusView.swift
//  Mottrix
//
//  Created by Hugues Mourice on 24/07/2025.
//

import SwiftUI

struct GameStatusView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var timerManager: TimerManager
    let themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 15) {
            switch viewModel.gameStatus {
            case .playing:
                Text("Tentative \(viewModel.game.currentGuessIndex + 1)/\(viewModel.game.maxAttempts)")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                    
            case .won:
                VStack(spacing: 10) {
                    Text("🎉 BRAVO! 🎉")
                        .font(.title)
                        .foregroundColor(.green)
                    Text("Trouvé en \(viewModel.game.currentGuessIndex + 1) essai(s)!")
                        .foregroundColor(themeManager.primaryTextColor)
                    
                    if timerManager.timeRemaining > 0 {
                        Text("Temps restant: \(timerManager.formattedTime)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
            case .lost:
                VStack(spacing: 10) {
                    Text("😞 Perdu!")
                        .font(.title)
                        .foregroundColor(.red)
                    Text("Le mot était: \(viewModel.game.targetWord)")
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryTextColor)
                }
            }
            
            if viewModel.gameStatus != .playing {
                Button("Nouvelle partie") {
                    viewModel.startNewGame()
                    timerManager.startTimer(duration: 300)
                    HapticManager.shared.success()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
    }
}
