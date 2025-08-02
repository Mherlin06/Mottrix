//  AuthManager.swift
//  Mottrix
//
//  Created by Hugues Mourice on 02/08/2025.
//


import FirebaseAuth
import FirebaseFirestore
import Foundation

class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    init() {
        // Écouter les changements d'auth (pour session persistante)
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = user != nil
                
                if let user = user {
                    self?.loadUserProfile(userId: user.uid)
                } else {
                    self?.userProfile = nil
                }
            }
        }
    }
    
    // MARK: - Inscription
    @MainActor
    func signUp(email: String, pseudo: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Créer le compte Firebase Auth
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Créer le profil en base
            let userProfile = UserProfile(
                id: result.user.uid,
                email: email,
                pseudo: pseudo
            )
            
            try await createUserProfile(userProfile)
            
        } catch {
            print("❌ Erreur inscription: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Connexion
    @MainActor
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            // Le profil sera chargé automatiquement via le listener
            
        } catch {
            print("❌ Erreur connexion: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Déconnexion
    func signOut() {
        do {
            try Auth.auth().signOut()
            // Les @Published seront mis à jour automatiquement
        } catch {
            print("❌ Erreur déconnexion: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Gestion du profil
    private func createUserProfile(_ profile: UserProfile) async throws {
        do {
            try await db.collection("users")
                .document(profile.id)
                .setData(profile.toDictionary())
            
            await MainActor.run {
                self.userProfile = profile
            }
            
            print("✅ Profil utilisateur créé: \(profile.pseudo)")
            
        } catch {
            print("❌ Erreur création profil: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func loadUserProfile(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Erreur chargement profil: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("❌ Aucune donnée profil trouvée")
                return
            }
            
            DispatchQueue.main.async {
                self?.userProfile = UserProfile(from: data, id: userId)
                print("✅ Profil chargé: \(self?.userProfile?.pseudo ?? "?")")
            }
        }
    }
    
    func updateLastLogin() {
        guard let userId = user?.uid else { return }
        
        db.collection("users").document(userId).updateData([
            "lastLoginAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("❌ Erreur mise à jour lastLogin: \(error.localizedDescription)")
            }
        }
    }
}
