// WelcomeView.swift - Version avec authentification
import Foundation
import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedDifficulty: Int = 5
    @State private var showGame = false
    @State private var showingMenu = false
    @State private var showingProfile = false
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header avec profil et menu
                HStack {
                    // Bouton profil utilisateur
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        showingProfile = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(authManager.userProfile?.pseudo ?? "...")
                                    .font(.headline)
                                    .foregroundColor(themeManager.primaryTextColor)
                                
                                Text("Connecté")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        showingMenu = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
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
        .sheet(isPresented: $showingMenu) {
            MenuView(themeManager: themeManager) {
                showingMenu = false
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView(themeManager: themeManager)
                .environmentObject(authManager)
        }
    }
}
