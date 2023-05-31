//
//  FitCountApp.swift
//  FitCount
//
//  Created by QuickPose.ai on 22.05.2023.
//

import SwiftUI
import QuickPoseCore

let exercises = [
    Exercise(
        name: "Biceps Curls",
        details: "Lift weights in both hands by bending your elbow and lifting them towards your shoulder.",
        features: [.fitness(.bicepsCurls), .overlay(.upperBody)]
    ),
    Exercise(
        name: "Squats",
        details: "Bend your knees and lower your body.",
        features: [.fitness(.squats), .overlay(.wholeBody)]
    ),

]

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let details: String
    let features: [QuickPose.Feature]
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
