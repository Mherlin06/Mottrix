//
//  MenuView.swift
//  Mottrix
//
//  Created by Hugues Mourice on 24/07/2025.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var themeManager: ThemeManager
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Paramètres")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryTextColor)
                    
                    VStack(spacing: 20) {
                        HStack {
                            Text("Thème sombre")
                                .font(.headline)
                                .foregroundColor(themeManager.primaryTextColor)
                            Spacer()
                            Toggle("", isOn: $themeManager.isDarkMode)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        
                        Divider()
                            .background(themeManager.primaryTextColor.opacity(0.3))
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Comment jouer")
                                .font(.headline)
                                .foregroundColor(themeManager.primaryTextColor)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("🟩")
                                    Text("Lettre correcte à la bonne place")
                                        .foregroundColor(themeManager.primaryTextColor)
                                }
                                
                                HStack {
                                    Text("🟨")
                                    Text("Lettre correcte à la mauvaise place")
                                        .foregroundColor(themeManager.primaryTextColor)
                                }
                                
                                HStack {
                                    Text("⬜")
                                    Text("Lettre absente du mot")
                                        .foregroundColor(themeManager.primaryTextColor)
                                }
                                
                                HStack {
                                    Text("💡")
                                    Text("La première lettre est donnée en indice")
                                        .foregroundColor(themeManager.primaryTextColor)
                                }
                            }
                            .font(.caption)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Retour au jeu") {
                        dismiss()
                        onDismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}
