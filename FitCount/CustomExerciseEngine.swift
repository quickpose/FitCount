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
    let alternativeRequirements: [[JointType: AngleRange]]? // Optional: any of these requirement sets can be satisfied
    let description: String
    
    init(id: String, name: String, requirements: [JointType: AngleRange], alternativeRequirements: [[JointType: AngleRange]]? = nil, description: String) {
        self.id = id
        self.name = name
        self.requirements = requirements
        self.alternativeRequirements = alternativeRequirements
        self.description = description
    }
    
    func meetsRequirements(angles: [JointType: Double]) -> Bool {
        // Check primary requirements
        var primaryMet = true
        for (joint, range) in requirements {
            guard let angle = angles[joint] else { 
                primaryMet = false
                break
            }
            if !range.contains(angle) { 
                primaryMet = false
                break
            }
        }
        
        if primaryMet {
            return true
        }
        
        // If primary requirements not met, check alternative requirements (OR logic)
        if let alternatives = alternativeRequirements {
            for altRequirements in alternatives {
                var altMet = true
                for (joint, range) in altRequirements {
                    guard let angle = angles[joint] else {
                        altMet = false
                        break
                    }
                    if !range.contains(angle) {
                        altMet = false
                        break
                    }
                }
                if altMet {
                    return true
                }
            }
        }
        
        return false
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
    let hideAOIVisualization: Bool
    
    init(id: String, name: String, description: String, stages: [ExerciseStage], requiredFeatures: [QuickPose.Feature], hideFeedback: Bool = false, hideAOIVisualization: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.stages = stages
        self.requiredFeatures = requiredFeatures
        self.hideFeedback = hideFeedback
        self.hideAOIVisualization = hideAOIVisualization
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
    @Published var aoiRect: CGRect? = nil // Area of Interest rectangle for visualization
    @Published var wristInAOI: Bool = false // Visual indicator for wrist in AOI
    
    internal var exercise: CustomExercise
    private var currentStageIndex: Int = 0
    private var lastRepTime: Date = Date()
    private var currentAngles: [JointType: Double] = [:]
    private var isInTransition: Bool = false
    
    // AOI and cooldown properties
    private var wristEnteredAOI: Bool = false
    private var wristWentAboveShoulder: Bool = false
    private var repCooldownPeriod: TimeInterval = 1.0
    
    init(exercise: CustomExercise) {
        self.exercise = exercise
        self.currentStage = exercise.stages.first?.name ?? ""
        // Initialize with first stage feedback only if feedback is not hidden
        if !exercise.hideFeedback, let firstStage = exercise.stages.first {
            self.feedbackMessage = "🔴 \(firstStage.name)\nGet into position"
        }
    }
    
    func processFrame(features: [QuickPose.Feature: QuickPose.FeatureResult], landmarks: QuickPose.Landmarks? = nil) -> Int {
        // Extract all range of motion angles
        updateAngles(from: features)
        
        // Check current stage requirements
        let currentExerciseStage = exercise.stages[currentStageIndex]
        let stageRequirementsMet = currentExerciseStage.meetsRequirements(angles: currentAngles)
        
        // Check if wrist entered zones WITH proper form (for kettlebell snatch)
        // Position checks ONLY count when corresponding stage angle requirements are met
        if let landmarks = landmarks {
            // Always update AOI visualization (called for every frame)
            let wristInAOI = checkWristAOI(landmarks: landmarks)
            let wristIsOverhead = checkWristAboveShoulder(landmarks: landmarks)
            
            // Check AOI entry when start position angles are correct
            let startStage = exercise.stages.first(where: { $0.id == "start_position" })
            if let startStage = startStage, startStage.meetsRequirements(angles: currentAngles) {
                if wristInAOI {
                    wristEnteredAOI = true
                }
            }
            
            // Check overhead when overhead position angles are correct
            let overheadStage = exercise.stages.first(where: { $0.id == "overhead_position" })
            if let overheadStage = overheadStage, overheadStage.meetsRequirements(angles: currentAngles) {
                if wristIsOverhead {
                    wristWentAboveShoulder = true
                }
            }
        }
        
        if stageRequirementsMet {
            if !isInTransition {
                // We've entered this stage
                isInTransition = true
                currentStage = currentExerciseStage.name
                
                // Move to next stage
                let nextStageIndex = (currentStageIndex + 1) % exercise.stages.count
                
                // If we've completed all stages, count a rep
                if nextStageIndex == 0 {
                    // Check cooldown period
                    let timeSinceLastRep = Date().timeIntervalSince(lastRepTime)
                    let cooldownElapsed = timeSinceLastRep >= repCooldownPeriod
                    
                    // For kettlebell snatch, also check AOI and overhead requirements
                    let isKettlebellSnatch = exercise.id == "standing_kettlebell_snatch"
                    let aoiRequirementMet = !isKettlebellSnatch || wristEnteredAOI
                    let overheadRequirementMet = !isKettlebellSnatch || wristWentAboveShoulder
                    
                    if cooldownElapsed && aoiRequirementMet && overheadRequirementMet {
                        currentReps += 1
                        lastRepTime = Date()
                        if !exercise.hideFeedback {
                            feedbackMessage = "🎉 Rep \(currentReps) Complete!\nStarting over..."
                        }
                        newRepCompleted = true
                        wristEnteredAOI = false // Reset for next rep
                        wristWentAboveShoulder = false // Reset for next rep
                    } else {
                        // Rep not counted - provide feedback with specific reason
                        if !cooldownElapsed {
                            if !exercise.hideFeedback {
                                feedbackMessage = "⏱️ Too fast!\nWait before next rep"
                            }
                        } else if !aoiRequirementMet {
                            if !exercise.hideFeedback {
                                feedbackMessage = "⚠️ Go lower!\nWrist in target zone with proper form"
                            }
                        } else if !overheadRequirementMet {
                            if !exercise.hideFeedback {
                                feedbackMessage = "⚠️ Go higher!\nWrist above shoulder with proper form"
                            }
                        }
                        newRepCompleted = false
                    }
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
    
    private func checkWristAOI(landmarks: QuickPose.Landmarks) -> Bool {
        // Only show AOI for kettlebell snatch exercise
        let isKettlebellSnatch = exercise.id == "standing_kettlebell_snatch"
        
        // Determine which arm is the working arm based on shoulder angles
        // Higher shoulder angle indicates overhead position (working arm)
        let leftShoulderAngle = currentAngles[.shoulder(side: .left)] ?? 0
        let rightShoulderAngle = currentAngles[.shoulder(side: .right)] ?? 0
        
        // Determine working side based on which arm has higher shoulder angle
        let workingArmIsLeft = leftShoulderAngle > rightShoulderAngle
        
        // Get landmark positions - landmarks return Point3d directly (not optional)
        let wrist = workingArmIsLeft ? 
            landmarks.landmark(forBody: .wrist(side: .left)) : 
            landmarks.landmark(forBody: .wrist(side: .right))
        let leftHip = landmarks.landmark(forBody: .hip(side: .left))
        let rightHip = landmarks.landmark(forBody: .hip(side: .right))
        let leftKnee = landmarks.landmark(forBody: .knee(side: .left))
        let rightKnee = landmarks.landmark(forBody: .knee(side: .right))
        
        // Calculate average hip and knee Y positions
        let avgHipY = (leftHip.y + rightHip.y) / 2
        let avgKneeY = (leftKnee.y + rightKnee.y) / 2
        
        // Current observation: Bottom of box is at hips, top extends upward by height
        // Goal: Top of box at hips, bottom extends downward to knees
        // Solution: Shift the entire box DOWN by the full height distance
        
        // Store the old minY calculation (which puts bottom at hips)
        let oldMinY = avgHipY  // This is what we had before
        
        // Calculate box height
        let boxHeight = abs(avgHipY - avgKneeY)
        
        // Shift minY down by the full height to flip the box
        // If Y increases upward (hips > knees): shift DOWN means subtract height
        // If Y increases downward (hips < knees): shift DOWN means add height  
        let boxMinY: CGFloat
        if avgHipY > avgKneeY {
            // Y increases upward, shift down means subtract
            boxMinY = oldMinY - boxHeight
        } else {
            // Y increases downward, shift down means add
            boxMinY = oldMinY + boxHeight
        }
        
        print("DEBUG: HipY=\(avgHipY), KneeY=\(avgKneeY), OldMinY=\(oldMinY), NewMinY=\(boxMinY), Height=\(boxHeight)")
        
        // For detection, check if wrist Y is between hip and knee levels
        let minY = min(avgHipY, avgKneeY)
        let maxY = max(avgHipY, avgKneeY)
        let wristInVerticalRange = wrist.y >= minY && wrist.y <= maxY
        
        // Check if wrist is between knees horizontally using normalized coordinates
        let leftKneeX = leftKnee.x
        let rightKneeX = rightKnee.x
        let wristX = wrist.x
        
        let minKneeX = min(leftKneeX, rightKneeX)
        let maxKneeX = max(leftKneeX, rightKneeX)
        let wristBetweenKnees = wristX >= minKneeX && wristX <= maxKneeX
        
        let isInAOI = wristInVerticalRange && wristBetweenKnees
        
        // Update AOI rectangle for visualization (normalized coordinates 0-1)
        // Only show visualization if not hidden
        if isKettlebellSnatch && !exercise.hideAOIVisualization {
            // CGRect: minY at hips (top), height extends down to knees (bottom)
            aoiRect = CGRect(
                x: minKneeX,
                y: boxMinY,  // Top at hips
                width: maxKneeX - minKneeX,
                height: boxHeight  // Extends down to knees
            )
            
            // Update real-time visual indicator
            wristInAOI = isInAOI
        } else {
            aoiRect = nil
            wristInAOI = false
        }
        
        return isInAOI
    }
    
    private func checkWristAboveShoulder(landmarks: QuickPose.Landmarks) -> Bool {
        // Only check for kettlebell snatch exercise
        let isKettlebellSnatch = exercise.id == "standing_kettlebell_snatch"
        guard isKettlebellSnatch else { return true }
        
        // Determine which arm is the working arm based on shoulder angles
        // Higher shoulder angle indicates overhead position (working arm)
        let leftShoulderAngle = currentAngles[.shoulder(side: .left)] ?? 0
        let rightShoulderAngle = currentAngles[.shoulder(side: .right)] ?? 0
        
        // Determine working side based on which arm has higher shoulder angle
        let workingArmIsLeft = leftShoulderAngle > rightShoulderAngle
        
        // Get landmark positions - landmarks return Point3d directly (not optional)
        let wrist = workingArmIsLeft ? 
            landmarks.landmark(forBody: .wrist(side: .left)) : 
            landmarks.landmark(forBody: .wrist(side: .right))
        let shoulder = workingArmIsLeft ? 
            landmarks.landmark(forBody: .shoulder(side: .left)) : 
            landmarks.landmark(forBody: .shoulder(side: .right))
        
        // Check if wrist is above shoulder (lower Y value = higher on screen)
        // In normalized coordinates: y increases downward (0 = top, 1 = bottom)
        let wristAboveShoulder = wrist.y < shoulder.y
        
        return wristAboveShoulder
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
        wristEnteredAOI = false
        wristWentAboveShoulder = false
        aoiRect = nil
        wristInAOI = false
    }
    
    // Debug helper
    func getCurrentAngles() -> String {
        return currentAngles.map { joint, angle in
            "\(joint.description): \(Int(angle))°"
        }.joined(separator: ", ")
    }
}
