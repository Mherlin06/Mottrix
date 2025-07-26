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
    @State private var timerScale: CGFloat = 1.0
    
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
                    // Header avec timer et menu
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
                        
                        Text("MOTTRIX")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.primaryTextColor)
                        
                        Spacer()
                        
                        if timerManager.shouldShowTimer {
                            Text(timerManager.formattedTime)
                                .font(.headline)
                                .fontWeight(timerManager.isCriticalTime ? .bold : .regular)
                                .foregroundColor(timerTextColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(timerBackgroundColor)
                                .cornerRadius(8)
                                .scaleEffect(timerScale)
                        } else {
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
                        firstLetter: viewModel.getFirstLetter(),
                        showSolutionWord: viewModel.showSolutionWord,
                        showVictoryWord: viewModel.showVictoryWord,
                        shouldShowFirstLetterHint: viewModel.shouldShowFirstLetterHint(),
                        firstLetterUsed: viewModel.firstLetterUsed
                    )
                    .padding(.horizontal)
                    
                    // Message d'erreur
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .transition(.opacity)
                    }
                    
                    // Clavier (désactivé si jeu terminé)
                    if viewModel.gameStatus == .playing {
                        EnhancedKeyboard(viewModel: viewModel, themeManager: themeManager)
                            .padding(.horizontal)
                    }
                    
                    // Status du jeu
                    EnhancedGameStatusView(
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
            // Démarrer le timer avec callback de fin - 60 secondes par défaut
            timerManager.startTimer(duration: 60) {
                viewModel.handleTimeExpired()
            }
        }
        .onChange(of: timerManager.isCriticalTime) { isCritical in
            if isCritical && timerManager.isRunning {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    timerScale = 1.1
                }
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    timerScale = 1.0
                }
            }
        }
        .onChange(of: viewModel.gameStatus) { status in
            if status != .playing {
                timerManager.stopTimer()
                withAnimation(.easeOut(duration: 0.2)) {
                    timerScale = 1.0
                }
            }
        }
        .sheet(isPresented: $showingMenu) {
            MenuView(themeManager: themeManager) {
                showingMenu = false
            }
        }
    }
    
    private var timerTextColor: Color {
        if !timerManager.isRunning && timerManager.hasExpired {
            return .red
        } else if timerManager.isCriticalTime {
            return .red
        } else if timerManager.isLowTime {
            return .orange
        } else {
            return themeManager.primaryTextColor
        }
    }
    
    private var timerBackgroundColor: Color {
        if !timerManager.isRunning && timerManager.hasExpired {
            return Color.red.opacity(0.1)
        } else if timerManager.isCriticalTime {
            return Color.red.opacity(0.1)
        } else if timerManager.isLowTime {
            return Color.orange.opacity(0.1)
        } else {
            return themeManager.secondaryBackgroundColor
        }
    }
}
