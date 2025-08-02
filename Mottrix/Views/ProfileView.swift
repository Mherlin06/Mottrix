//
//  ProfileView.swift
//  Mottrix
//
//  Created by Hugues Mourice on 02/08/2025.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    let themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Avatar et infos
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text(authManager.userProfile?.pseudo ?? "Utilisateur")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.primaryTextColor)
                        
                        Text(authManager.userProfile?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        if let createdAt = authManager.userProfile?.createdAt {
                            Text("Membre depuis \(createdAt.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // Bouton déconnexion
                    Button("Se déconnecter") {
                        authManager.signOut()
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Profil")
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
