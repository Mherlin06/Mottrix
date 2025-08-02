//
//  UserProfile.swift
//  Mottrix
//
//  Created by Hugues Mourice on 02/08/2025.
//


import Foundation
import FirebaseFirestore

struct UserProfile: Codable, Identifiable {
    let id: String
    let email: String
    let pseudo: String
    let createdAt: Date
    var lastLoginAt: Date?
    
    init(id: String, email: String, pseudo: String) {
        self.id = id
        self.email = email
        self.pseudo = pseudo
        self.createdAt = Date()
        self.lastLoginAt = Date()
    }
    
    init(from data: [String: Any], id: String) {
        self.id = id
        self.email = data["email"] as? String ?? ""
        self.pseudo = data["pseudo"] as? String ?? ""
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.lastLoginAt = (data["lastLoginAt"] as? Timestamp)?.dateValue()
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "email": email,
            "pseudo": pseudo,
            "createdAt": Timestamp(date: createdAt),
            "lastLoginAt": Timestamp(date: lastLoginAt ?? Date())
        ]
    }
}