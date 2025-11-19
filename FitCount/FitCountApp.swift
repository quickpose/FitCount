//
//  FitCountApp.swift
//  FitCount
//
//  Created by QuickPose.ai on 22.05.2023.
//

import SwiftUI
import QuickPoseCore


struct Exercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let details: String
    let features: [QuickPose.Feature]
    let isCustomExercise: Bool
    
    init(name: String, details: String, features: [QuickPose.Feature], isCustomExercise: Bool = false) {
        self.name = name
        self.details = details
        self.features = features
        self.isCustomExercise = isCustomExercise
    }
}

let exercises = [
    Exercise(
        name: "Bicep Curls",
        details: "Lift weights in both hands by bending your elbow and lifting them towards your shoulder.",
        features: [.fitness(.bicepCurls), .overlay(.upperBody)]
    ),
    Exercise(
        name: "Squats",
        details: "Bend your knees and lower your body.",
        features: [.fitness(.squats), .overlay(.wholeBody)]
    ),
    Exercise(
        name: "Overhead Dumbbell Press",
        details: "Stand with feet shoulder-width apart, hold dumbbells at shoulder height, and press them overhead until arms are fully extended.",
        features: [.fitness(.overheadDumbbellPress), .overlay(.upperBody)]
    ),
    SideTiltsExercise.createExercise().exerciseDefinition,
    KneeRaisesExercise.createExercise().exerciseDefinition,
    FrontPushupExercise.createExercise().exerciseDefinition,
]


@main
struct FitCountApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
