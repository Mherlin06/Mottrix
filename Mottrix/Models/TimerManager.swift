//
//  TimerManager.swift
//  Mottrix
//
//  Created by Hugues Mourice on 24/07/2025.
//

import SwiftUI

class TimerManager: ObservableObject {
    @Published var timeRemaining: Int = 60 // 1 minute par défaut
    @Published var isRunning: Bool = false
    
    private var timer: Timer?
    
    func startTimer(duration: Int = 60) {
        timeRemaining = duration
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func resetTimer(duration: Int = 60) {
        stopTimer()
        timeRemaining = duration
    }
    
    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

