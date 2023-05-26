//
//  FitCountApp.swift
//  FitCount
//
//  Created by QuickPose.ai on 22.05.2023.
//

import SwiftUI

let exercises = [
    Exercise(name: "Biceps Curls", details: "Lift weights in both hands by bending your elbow and lifting them towards your shoulder."),
    Exercise(name: "Biceps Curls 2", details: "Lift weights in both hands by bending your elbow and lifting them towards your shoulder.")

]

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let details: String
    // Add more properties as needed
}

@main
struct FitCountApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
