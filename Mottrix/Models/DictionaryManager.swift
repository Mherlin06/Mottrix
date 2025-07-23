//
//  DictionaryManager.swift
//  Mottrix
//
//  Created by Hugues Mourice on 23/07/2025.
//


import Foundation

class DictionaryManager {
    static let shared = DictionaryManager()
    
    // Mots de test pour développer (on remplacera plus tard)
    private let testWords: [Int: [String]] = [
        5: ["MAISON", "CHIEN", "FLEUR", "TABLE", "LIVRE", "ROUGE", "BLANC", "VERT"],
        6: ["JARDIN", "FENETRE", "CHAISE", "ORANGE", "VIOLET", "JAUNE"],
        7: ["CUISINE", "BALCON", "CHAMBRE", "ARMOIRE", "LUMIERE"],
        8: ["ESCALIER", "TELEPHONE", "ORDINATEUR", "TELEVISION"]
    ]
    
    private let validWords: Set<String> = [] // Pour validation plus tard
    
    private init() {}
    
    func getRandomWord(length: Int) -> String? {
        guard let words = testWords[length], !words.isEmpty else {
            return nil
        }
        return words.randomElement()
    }
    
    func isValidWord(_ word: String) -> Bool {
        let upperWord = word.uppercased()
        
        // Pour l'instant, on vérifie juste dans nos mots de test
        for (_, words) in testWords {
            if words.contains(upperWord) {
                return true
            }
        }
        
        return false
    }
}