//
//  GameView.swift
//  Mottrix
//
//  Created by Hugues Mourice on 24/07/2025.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @StateObject private var timerManager = TimerManager()
    @ObservedObject var themeManager: ThemeManager
    @State private var showingMenu = false
    
    init(difficulty: Int, themeManager: ThemeManager) {
        self._viewModel = StateObject(wrappedValue: GameViewModel(difficulty: difficulty))
        self.themeManager = themeManager
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header avec timer et menu (icône engrenage)
                    HStack {
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            showingMenu = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Text("MOTRIX")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.primaryTextColor)
                        
                        Spacer()
                        
                        if timerManager.isRunning {
                            Text(timerManager.formattedTime)
                                .font(.headline)
                                .foregroundColor(timerManager.timeRemaining < 10 ? .red : themeManager.primaryTextColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(themeManager.secondaryBackgroundColor)
                                .cornerRadius(8)
                        } else {
                            // Espace réservé pour maintenir l'alignement
                            Color.clear
                                .frame(width: 80, height: 30)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Grille de jeu responsive
                    EnhancedGridView(
                        game: viewModel.game,
                        currentInput: viewModel.currentInput,
                        themeManager: themeManager,
                        firstLetter: viewModel.getFirstLetter()
                    )
                    .padding(.horizontal)
                    
                    // Message d'erreur
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .transition(.opacity)
                    }
                    
                    // Clavier amélioré
                    EnhancedKeyboard(viewModel: viewModel, themeManager: themeManager)
                        .padding(.horizontal)
                    
                    // Status du jeu
                    GameStatusView(
                        viewModel: viewModel,
                        timerManager: timerManager,
                        themeManager: themeManager
                    )
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
        }
        .onAppear {
            timerManager.startTimer(duration: 300) // 5 minutes
        }
        .onChange(of: viewModel.gameStatus) { status in
            if status != .playing {
                timerManager.stopTimer()
            }
        }
        .sheet(isPresented: $showingMenu) {
            MenuView(themeManager: themeManager) {
                showingMenu = false
            }
        }
    }
}
