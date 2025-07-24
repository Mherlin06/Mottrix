//
//  ThemeManager.swift
//  Mottrix
//
//  Created by Hugues Mourice on 24/07/2025.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    
    var backgroundColor: Color {
        isDarkMode ? Color.black : Color.white
    }
    
    var primaryTextColor: Color {
        isDarkMode ? Color.white : Color.black
    }
    
    var secondaryBackgroundColor: Color {
        isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1)
    }
}
