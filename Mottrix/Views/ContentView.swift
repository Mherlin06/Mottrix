// ContentView.swift - Version avec authentification
import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated && authManager.userProfile != nil {
                // Utilisateur connecté → Interface de jeu
                WelcomeView()
                    .environmentObject(authManager)
                    .environmentObject(themeManager)
            } else if authManager.isAuthenticated && authManager.userProfile == nil {
                // Connecté mais profil en cours de chargement
                LoadingView(themeManager: themeManager)
            } else {
                // Non connecté → Écran d'authentification
                AuthView(themeManager: themeManager)
                    .environmentObject(authManager)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
    }
}

struct LoadingView: View {
    let themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("🎯")
                    .font(.system(size: 60))
                
                Text("MOTTRIX")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.primaryTextColor)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                
                Text("Chargement...")
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    ContentView()
}
