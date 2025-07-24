//
//  WelcomeView.swift
//  Mottrix
//
//  Created by Hugues Mourice on 24/07/2025.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedDifficulty: Int = 5
    @State private var showGame = false
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo et titre
                VStack(spacing: 10) {
                    Text("🎯")
                        .font(.system(size: 80))
                    
                    Text("MOTTRIX")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryTextColor)
                    
                    Text("Le jeu de mots français")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Sélection de difficulté
                VStack(spacing: 15) {
                    Text("Choisissez votre difficulté")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)
                    
                    ForEach(5...8, id: \.self) { length in
                        DifficultyCard(
                            length: length,
                            isSelected: selectedDifficulty == length,
                            themeManager: themeManager
                        ) {
                            selectedDifficulty = length
                            HapticManager.shared.lightImpact()
                        }
                    }
                }
                
                // Toggle thème sombre
                HStack {
                    Text("Thème sombre")
                        .foregroundColor(themeManager.primaryTextColor)
                    
                    Spacer()
                    
                    Toggle("", isOn: $themeManager.isDarkMode)
                        .onChange(of: themeManager.isDarkMode) { _ in
                            HapticManager.shared.lightImpact()
                        }
                }
                .padding(.horizontal)
                
                // Bouton Jouer
                Button("JOUER") {
                    HapticManager.shared.mediumImpact()
                    showGame = true
                }
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showGame) {
            GameView(
                difficulty: selectedDifficulty,
                themeManager: themeManager
            )
        }
    }
}
