//
//  AuthView.swift
//  Mottrix
//
//  Created by Hugues Mourice on 02/08/2025.
//


import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var themeManager: ThemeManager
    
    @State private var isSignUp = false
    @State private var email = ""
    @State private var pseudo = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 50)
                    
                    // Logo Mottrix
                    VStack(spacing: 15) {
                        Text("🎯")
                            .font(.system(size: 80))
                        
                        Text("MOTTRIX")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.primaryTextColor)
                        
                        Text(isSignUp ? "Créer un compte" : "Connexion")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    
                    // Formulaire
                    VStack(spacing: 15) {
                        // Email
                        TextField("Email", text: $email)
                            .textFieldStyle(MottrixTextFieldStyle(themeManager: themeManager))
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        // Pseudo (uniquement inscription)
                        if isSignUp {
                            TextField("Pseudo", text: $pseudo)
                                .textFieldStyle(MottrixTextFieldStyle(themeManager: themeManager))
                        }
                        
                        // Mot de passe
                        SecureField("Mot de passe", text: $password)
                            .textFieldStyle(MottrixTextFieldStyle(themeManager: themeManager))
                        
                        // Confirmation mot de passe (uniquement inscription)
                        if isSignUp {
                            SecureField("Confirmer le mot de passe", text: $confirmPassword)
                                .textFieldStyle(MottrixTextFieldStyle(themeManager: themeManager))
                        }
                    }
                    
                    // Message d'erreur
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Boutons
                    VStack(spacing: 15) {
                        // Bouton principal
                        Button(action: handleSubmit) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text(isSignUp ? "CRÉER LE COMPTE" : "SE CONNECTER")
                                        .fontWeight(.bold)
                                }
                            }
                        }
                        .buttonStyle(MottrixButtonStyle())
                        .disabled(authManager.isLoading)
                        
                        // Bouton bascule
                        Button(action: {
                            isSignUp.toggle()
                            clearForm()
                            HapticManager.shared.lightImpact()
                        }) {
                            Text(isSignUp ? "Déjà un compte ? Se connecter" : "Pas de compte ? S'inscrire")
                                .foregroundColor(.blue)
                                .font(.headline)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func handleSubmit() {
        guard validateInput() else { return }
        
        Task {
            do {
                if isSignUp {
                    try await authManager.signUp(email: email, pseudo: pseudo, password: password)
                    HapticManager.shared.success()
                } else {
                    try await authManager.signIn(email: email, password: password)
                    HapticManager.shared.success()
                    authManager.updateLastLogin()
                }
                
                await MainActor.run {
                    clearForm()
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = getErrorMessage(from: error)
                    HapticManager.shared.error()
                }
            }
        }
    }
    
    private func validateInput() -> Bool {
        errorMessage = ""
        
        if email.isEmpty {
            errorMessage = "L'email est requis"
            return false
        }
        
        if !email.contains("@") {
            errorMessage = "Email invalide"
            return false
        }
        
        if password.isEmpty {
            errorMessage = "Le mot de passe est requis"
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Le mot de passe doit faire au moins 6 caractères"
            return false
        }
        
        if isSignUp {
            if pseudo.isEmpty {
                errorMessage = "Le pseudo est requis"
                return false
            }
            
            if pseudo.count < 2 {
                errorMessage = "Le pseudo doit faire au moins 2 caractères"
                return false
            }
            
            if password != confirmPassword {
                errorMessage = "Les mots de passe ne correspondent pas"
                return false
            }
        }
        
        return true
    }
    
    private func clearForm() {
        email = ""
        pseudo = ""
        password = ""
        confirmPassword = ""
        errorMessage = ""
    }
    
    private func getErrorMessage(from error: Error) -> String {
        if let authError = error as NSError? {
            switch authError.code {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                return "Cette adresse email est déjà utilisée"
            case AuthErrorCode.weakPassword.rawValue:
                return "Le mot de passe est trop faible"
            case AuthErrorCode.invalidEmail.rawValue:
                return "Adresse email invalide"
            case AuthErrorCode.userNotFound.rawValue:
                return "Aucun compte trouvé avec cet email"
            case AuthErrorCode.wrongPassword.rawValue:
                return "Mot de passe incorrect"
            default:
                return "Erreur: \(error.localizedDescription)"
            }
        }
        return "Une erreur est survenue"
    }
}

// Extension pour cacher le clavier
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
