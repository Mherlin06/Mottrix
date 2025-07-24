//
//  DictionaryManager.swift
//  Mottrix
//
//  Created by Hugues Mourice on 23/07/2025.
//


import Foundation

class DictionaryManager {
    static let shared = DictionaryManager()
    
    private var wordsByLength: [Int: [String]] = [:]
    private var allValidWords: Set<String> = []
    
    private init() {
        loadFrenchWords()
    }
    
    private func loadFrenchWords() {
        guard let path = Bundle.main.path(forResource: "french_words", ofType: "txt"),
              let content = try? String(contentsOfFile: path) else {
            print("❌ Impossible de charger le fichier french_words.txt")
            loadFallbackWords()
            return
        }
        
        let words = content.components(separatedBy: .newlines)
            .map { $0.uppercased().trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.allSatisfy { $0.isLetter } }
        
        // Organiser par longueur
        for word in words {
            let length = word.count
            if length >= 5 && length <= 8 {
                wordsByLength[length, default: []].append(word)
                allValidWords.insert(word)
            }
        }
        
        // Statistiques
        print("✅ Dictionnaire français chargé:")
        for length in 5...8 {
            let count = wordsByLength[length]?.count ?? 0
            print("   \(length) lettres: \(count) mots")
        }
        print("   Total: \(allValidWords.count) mots")
    }
    
    private func loadFallbackWords() {
        print("📝 Chargement des mots de secours...")
        
        // Mots de secours en attendant le vrai fichier
        wordsByLength[5] = ["ABORD", "ACHAT", "ACIER", "ADIEU", "AGENT", "AIDER", "AIGLE", "AIMER", "AINSI", "ALBUM"]
        wordsByLength[6] = ["ABIMER", "ABSORB", "ACCENT", "ACCORD", "ACHETE", "ACTIVE", "ADIEUX", "ADMIRE", "ADULTE"]
        wordsByLength[7] = ["ABSENCE", "ACADEMY", "ACCOUNT", "ACHIEVE", "ACQUIRE", "ADDRESS", "ADVANCE"]
        wordsByLength[8] = ["ABSOLUTE", "ABSTRACT", "ACADEMIC", "ACCEPTED", "ACCIDENT", "ACCURATE"]
        
        allValidWords = Set((wordsByLength[5] ?? []) + (wordsByLength[6] ?? []) + (wordsByLength[7] ?? []) + (wordsByLength[8] ?? []))
        
        print("📝 Mots de secours chargés: \(allValidWords.count) mots")
    }
    
    func getRandomWord(length: Int) -> String? {
        guard let words = wordsByLength[length], !words.isEmpty else {
            print("❌ Aucun mot trouvé pour la longueur \(length)")
            return nil
        }
        
        let randomWord = words.randomElement()
        print("🎲 Mot sélectionné: \(randomWord ?? "ERREUR") (\(length) lettres)")
        return randomWord
    }
    
    func isValidWord(_ word: String) -> Bool {
        let upperWord = word.uppercased()
        if allValidWords.contains(upperWord){
            return true
        } else {
            print("❌ Mot '\(upperWord)' non trouvé dans le dictionnaire")
            return false
        }
        
    }
    
    func getWordCount(for length: Int) -> Int {
        return wordsByLength[length]?.count ?? 0
    }
    
    func getAllWords(for length: Int) -> [String] {
        return wordsByLength[length] ?? []
    }
    
    // Fonction pour recharger le dictionnaire (utile pour debug)
    func reloadDictionary() {
        wordsByLength.removeAll()
        allValidWords.removeAll()
        loadFrenchWords()
    }
}
