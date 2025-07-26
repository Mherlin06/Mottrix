//
//  TimerManager.swift
//  Mottrix
//
//  Created by Hugues Mourice on 24/07/2025.
//

import SwiftUI

class TimerManager: ObservableObject {
    @Published var timeRemaining: Int = 60
    @Published var isRunning: Bool = false
    @Published var hasExpired: Bool = false
    
    private var timer: Timer?
    private var onTimeExpired: (() -> Void)?
    
    func startTimer(duration: Int = 60, onExpired: (() -> Void)? = nil) {
        timeRemaining = duration
        isRunning = true
        hasExpired = false
        onTimeExpired = onExpired
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
                self.hasExpired = true
                self.onTimeExpired?() // Appeler le callback de fin de temps
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        // Note: on ne remet pas hasExpired à false ici pour garder l'état
    }
    
    func resetTimer(duration: Int = 60) {
        stopTimer()
        timeRemaining = duration
        hasExpired = false
    }
    
    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var isLowTime: Bool {
        return timeRemaining <= 30 && timeRemaining > 10 && isRunning
    }
    
    var isCriticalTime: Bool {
        return timeRemaining <= 10 && timeRemaining > 0 && isRunning
    }
    
    // Nouvelle propriété pour savoir si on doit encore afficher le timer
    var shouldShowTimer: Bool {
        return isRunning || (hasExpired && timeRemaining == 0)
    }
}
