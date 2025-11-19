//
//  CustomExerciseEngine.swift
//  FitCount
//
//  Created by QuickPose.ai
//

import SwiftUI
import QuickPoseCore
import Foundation

// MARK: - Joint Angle Definitions
enum JointSide: Hashable {
    case left, right
}

struct AngleRange: Hashable {
    let min: Double
    let max: Double
    
    func contains(_ angle: Double) -> Bool {
        // Handle ranges that cross the 0° boundary (e.g., 340° to 90°)
        if min > max {
            // Range crosses 0° boundary: angle is in range if it's >= min OR <= max
            return angle >= min || angle <= max
        } else {
            // Normal range: angle is in range if it's between min and max
            return angle >= min && angle <= max
        }
    }
    
    var description: String {
        if min > max {
            // Show wraparound range more clearly
            return "\(Int(min))° - 0° - \(Int(max))°"
        } else {
            return "\(Int(min)) - \(Int(max))°"
        }
    }
}

enum JointType: Hashable {
    case elbow(side: JointSide)
    case shoulder(side: JointSide) 
    case knee(side: JointSide)
    case hip(side: JointSide)
    
    var description: String {
        switch self {
        case .elbow(let side): return "\(side == .left ? "Left" : "Right") Elbow"
        case .shoulder(let side): return "\(side == .left ? "Left" : "Right") Shoulder"
        case .knee(let side): return "\(side == .left ? "Left" : "Right") Knee"
        case .hip(let side): return "\(side == .left ? "Left" : "Right") Hip"
        }
    }
}

// MARK: - Exercise Stage Definition
struct ExerciseStage {
    let id: String
    let name: String
    let requirements: [JointType: AngleRange]
    let description: String
    
    func meetsRequirements(angles: [JointType: Double]) -> Bool {
        for (joint, range) in requirements {
            guard let angle = angles[joint] else { return false }
            if !range.contains(angle) { return false }
        }
        return true
    }
}

// MARK: - Custom Exercise Definition
struct CustomExercise {
    let id: String
    let name: String
    let description: String
    let stages: [ExerciseStage]
    let requiredFeatures: [QuickPose.Feature]
    let hideFeedback: Bool
    
    init(id: String, name: String, description: String, stages: [ExerciseStage], requiredFeatures: [QuickPose.Feature], hideFeedback: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.stages = stages
        self.requiredFeatures = requiredFeatures
        self.hideFeedback = hideFeedback
    }
    
    var exerciseDefinition: Exercise {
        return Exercise(
            name: name,
            details: description,
            features: requiredFeatures,
            isCustomExercise: true
        )
    }
}

// MARK: - Custom Exercise Engine
class CustomExerciseEngine: ObservableObject {
    @Published var currentReps: Int = 0
    @Published var currentStage: String = ""
    @Published var feedbackMessage: String = ""
    @Published var newRepCompleted: Bool = false
    @Published var incorrectJoints: Set<JointType> = []
    
    internal var exercise: CustomExercise
    private var currentStageIndex: Int = 0
    private var lastRepTime: Date = Date()
    private var currentAngles: [JointType: Double] = [:]
    private var isInTransition: Bool = false
    
    init(exercise: CustomExercise) {
        self.exercise = exercise
        self.currentStage = exercise.stages.first?.name ?? ""
        // Initialize with first stage feedback only if feedback is not hidden
        if !exercise.hideFeedback, let firstStage = exercise.stages.first {
            self.feedbackMessage = "🔴 \(firstStage.name)\nGet into position"
        }
    }
    
    func processFrame(features: [QuickPose.Feature: QuickPose.FeatureResult]) -> Int {
        // Extract all range of motion angles
        updateAngles(from: features)
        
        // Check current stage requirements
        let currentExerciseStage = exercise.stages[currentStageIndex]
        
        if currentExerciseStage.meetsRequirements(angles: currentAngles) {
            if !isInTransition {
                // We've entered this stage
                isInTransition = true
                currentStage = currentExerciseStage.name
                
                // Move to next stage
                let nextStageIndex = (currentStageIndex + 1) % exercise.stages.count
                
                // If we've completed all stages, count a rep
                if nextStageIndex == 0 {
                    currentReps += 1
                    lastRepTime = Date()
                    if !exercise.hideFeedback {
                        feedbackMessage = "🎉 Rep \(currentReps) Complete!\nStarting over..."
                    }
                    newRepCompleted = true
                } else {
                    let nextStage = exercise.stages[nextStageIndex]
                    if !exercise.hideFeedback {
                        feedbackMessage = "✅ \(currentExerciseStage.name)\nNext: \(nextStage.name)"
                    }
                    newRepCompleted = false
                }
                
                currentStageIndex = nextStageIndex
            }
        } else {
            isInTransition = false
            // Provide feedback on what's needed
            updateFeedback(for: currentExerciseStage)
        }
        
        return currentReps
    }
    
    private func updateAngles(from features: [QuickPose.Feature: QuickPose.FeatureResult]) {
        // Get the current stage requirements to determine which direction we need
        let currentStageRequirements = exercise.stages[currentStageIndex].requirements
        
        for feature in features.keys {
            if let result = features[feature] {
                let angle = result.value
                
                if case .rangeOfMotion(let joint, _) = feature {
                    // For now, let's simplify and just use all range of motion measurements
                    // The direction logic was too complex - let's see what measurements we actually get
                    switch joint {
                    case .shoulder(side: .left, _):
                        currentAngles[.shoulder(side: .left)] = angle
                    case .shoulder(side: .right, _):
                        currentAngles[.shoulder(side: .right)] = angle
                    case .elbow(side: .left, _):
                        currentAngles[.elbow(side: .left)] = angle
                    case .elbow(side: .right, _):
                        currentAngles[.elbow(side: .right)] = angle
                    case .knee(side: .left, _):
                        currentAngles[.knee(side: .left)] = angle
                    case .knee(side: .right, _):
                        currentAngles[.knee(side: .right)] = angle
                    case .hip(side: .left, _):
                        currentAngles[.hip(side: .left)] = angle
                    case .hip(side: .right, _):
                        currentAngles[.hip(side: .right)] = angle
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func updateFeedback(for stage: ExerciseStage) {
        // Check if feedback should be hidden
        if exercise.hideFeedback {
            feedbackMessage = ""
            return
        }
        
        var missingRequirements: [String] = []
        var incorrectJointsSet: Set<JointType> = []
        
        for (joint, range) in stage.requirements {
            if let angle = currentAngles[joint] {
                if !range.contains(angle) {
                    let jointName = joint.description.replacingOccurrences(of: "Left ", with: "L-").replacingOccurrences(of: "Right ", with: "R-")
                    missingRequirements.append("\(jointName): \(Int(angle))° (need \(range.description))")
                    incorrectJointsSet.insert(joint)
                }
            } else {
                let jointName = joint.description.replacingOccurrences(of: "Left ", with: "L-").replacingOccurrences(of: "Right ", with: "R-")
                missingRequirements.append("\(jointName): Not detected")
                incorrectJointsSet.insert(joint)
            }
        }
        
        // Update the published set of incorrect joints
        incorrectJoints = incorrectJointsSet
        
        if missingRequirements.isEmpty {
            feedbackMessage = "✅ \(stage.name)\nPerfect! Moving to next stage"
        } else if missingRequirements.count == 1 {
            feedbackMessage = "🔴 \(stage.name)\n\(missingRequirements.first!)"
        } else if missingRequirements.count <= 3 {
            feedbackMessage = "🔴 \(stage.name)\n\(missingRequirements.prefix(2).joined(separator: "\n"))"
        } else {
            feedbackMessage = "🔴 \(stage.name)\nAdjust \(missingRequirements.count) joints"
        }
    }
    
    func reset() {
        currentReps = 0
        currentStageIndex = 0
        currentStage = exercise.stages.first?.name ?? ""
        // Initialize with first stage feedback only if feedback is not hidden
        if !exercise.hideFeedback, let firstStage = exercise.stages.first {
            feedbackMessage = "🔴 \(firstStage.name)\nGet into position"
        } else {
            feedbackMessage = ""
        }
        isInTransition = false
        currentAngles.removeAll()
        incorrectJoints.removeAll()
    }
    
    // Debug helper
    func getCurrentAngles() -> String {
        return currentAngles.map { joint, angle in
            "\(joint.description): \(Int(angle))°"
        }.joined(separator: ", ")
    }
}
