//
//  Timer.swift
//  FitCount
//
//  Created by QuickPose.ai on 25.05.2023.
//

import Foundation

class TimerManager {
    private var timer: Timer?
    private var startDate: Date?
    private var totalSeconds: TimeInterval = 0
    
    func start() {
        if timer == nil {
            startDate = Date()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        startDate = nil
        totalSeconds = 0
    }
    
    func isRunning() -> Bool {
        return timer != nil
    }
    
    func getTotalSeconds() -> TimeInterval {
        if let startDate = startDate {
            return totalSeconds + Date().timeIntervalSince(startDate)
        } else {
            return totalSeconds
        }
    }
    
    @objc private func updateTimer() {
        totalSeconds += 1
        // Update UI or perform any other action with the updated timer value
    }
}
