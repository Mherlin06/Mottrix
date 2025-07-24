//
//  DifficultyCard.swift
//  Mottrix
//
//  Created by Hugues Mourice on 24/07/2025.
//

import SwiftUI

struct DifficultyCard: View {
    let length: Int
    let isSelected: Bool
    let themeManager: ThemeManager
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(length) lettres")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)
                    
                    Text("\(DictionaryManager.shared.getWordCount(for: length)) mots")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(difficultyLevel)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(difficultyColor.opacity(0.2))
                    .foregroundColor(difficultyColor)
                    .cornerRadius(8)
            }
            .padding()
            .background(
                isSelected ?
                difficultyColor.opacity(0.1) :
                themeManager.secondaryBackgroundColor
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? difficultyColor : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .padding(.horizontal)
    }
    
    private var difficultyLevel: String {
        switch length {
        case 5: return "Facile"
        case 6: return "Moyen"
        case 7: return "Difficile"
        case 8: return "Expert"
        default: return "?"
        }
    }
    
    private var difficultyColor: Color {
        switch length {
        case 5: return .green
        case 6: return .blue
        case 7: return .orange
        case 8: return .red
        default: return .gray
        }
    }
}
