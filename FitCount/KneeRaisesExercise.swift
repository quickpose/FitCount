//
//  KneeRaisesExercise.swift
//  FitCount
//
//  Created by QuickPose.ai
//

import Foundation
import QuickPoseCore

// MARK: - Knee Raises Exercise Definition
class KneeRaisesExercise {
    static func createExercise(hideFeedback: Bool = true) -> CustomExercise {
        let stages = [
            // Stage 1: Start Position
            ExerciseStage(
                id: "start_position",
                name: "Start Position",
                requirements: [
                    .knee(side: .left): AngleRange(min: 150, max: 200),
                    .knee(side: .right): AngleRange(min: 150, max: 200),
                    .elbow(side: .left): AngleRange(min: 150, max: 200),
                    .elbow(side: .right): AngleRange(min: 150, max: 200)
                ],
                description: "Stand upright with both knees and elbows in relaxed position"
            ),
            
            // Stage 2: Right Knee Up
            ExerciseStage(
                id: "right_knee_up",
                name: "Right Knee Up",
                requirements: [
                    .knee(side: .right): AngleRange(min: 340, max: 90),
                    .knee(side: .left): AngleRange(min: 150, max: 200),
                    .elbow(side: .right): AngleRange(min: 90, max: 180),
                    .elbow(side: .left): AngleRange(min: 90, max: 180)
                ],
                description: "Raise your right knee up while keeping elbows bent"
            ),
            
            // Stage 3: Back to Middle
            ExerciseStage(
                id: "back_to_middle",
                name: "Back to Middle",
                requirements: [
                    .knee(side: .left): AngleRange(min: 150, max: 200),
                    .knee(side: .right): AngleRange(min: 150, max: 200),
                    .elbow(side: .left): AngleRange(min: 150, max: 200),
                    .elbow(side: .right): AngleRange(min: 150, max: 200)
                ],
                description: "Return to center position with both knees and elbows relaxed"
            ),
            
            // Stage 4: Left Knee Up
            ExerciseStage(
                id: "left_knee_up",
                name: "Left Knee Up",
                requirements: [
                    .knee(side: .right): AngleRange(min: 150, max: 200),
                    .knee(side: .left): AngleRange(min: 340, max: 90),
                    .elbow(side: .right): AngleRange(min: 90, max: 180),
                    .elbow(side: .left): AngleRange(min: 90, max: 180)
                ],
                description: "Raise your left knee up while keeping elbows bent"
            )
        ]
        
        // Define the required QuickPose features for range of motion tracking
        // Create custom styles for overlay
        let lightOverlayStyle = QuickPose.Style(relativeFontSize: 0.0, relativeArcSize: 0.0, relativeLineWidth: 1.0)
        let noOverlayStyle = QuickPose.Style(relativeFontSize: 0.0, relativeArcSize: 0.0, relativeLineWidth: 0.0)
        
        let requiredFeatures: [QuickPose.Feature] = [
            // Knee tracking with clockwise direction as specified
            .rangeOfMotion(.knee(side: .right, clockwiseDirection: true), style: lightOverlayStyle),
            .rangeOfMotion(.knee(side: .left, clockwiseDirection: true), style: lightOverlayStyle),
            // Elbow tracking - Right elbow ACW (false), Left elbow CW (true)
            .rangeOfMotion(.elbow(side: .right, clockwiseDirection: false), style: lightOverlayStyle),
            .rangeOfMotion(.elbow(side: .left, clockwiseDirection: true), style: lightOverlayStyle),
            .overlay(.wholeBody, style: noOverlayStyle) // Light body outline
        ]
        
        return CustomExercise(
            id: "knee_raises",
            name: "Knee Raises",
            description: "Alternating knee raises while maintaining elbow position to strengthen core and improve leg mobility.",
            stages: stages,
            requiredFeatures: requiredFeatures,
            hideFeedback: hideFeedback
        )
    }
}
