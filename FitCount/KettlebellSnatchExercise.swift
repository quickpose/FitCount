//
//  KettlebellSnatchExercise.swift
//  FitCount
//
//  Created by QuickPose.ai
//

import Foundation
import QuickPoseCore

// MARK: - Standing Kettlebell Snatch Exercise Definition
class KettlebellSnatchExercise {
    static func createExercise(hideFeedback: Bool = true, showAOI: Bool = false) -> CustomExercise {
        let stages = [
            // Stage 1: Start Position (Either Left OR Right Arm Down)
            ExerciseStage(
                id: "start_position",
                name: "Start Position",
                requirements: [
                    // Primary: Check left arm down
                    .elbow(side: .left): AngleRange(min: 150, max: 200),
                    .shoulder(side: .left): AngleRange(min: 10, max: 70)
                ],
                alternativeRequirements: [
                    // Alternative: Check right arm down
                    [
                        .elbow(side: .right): AngleRange(min: 150, max: 200),
                        .shoulder(side: .right): AngleRange(min: 10, max: 70)
                    ]
                ],
                description: "Stand with one arm down at your side"
            ),
            
            // Stage 2: Overhead Position (Either Left OR Right Arm Up)
            ExerciseStage(
                id: "overhead_position",
                name: "Overhead Position",
                requirements: [
                    // Primary: Check left arm overhead
                    .elbow(side: .left): AngleRange(min: 150, max: 210),
                    .shoulder(side: .left): AngleRange(min: 140, max: 210)
                ],
                alternativeRequirements: [
                    // Alternative: Check right arm overhead
                    [
                        .elbow(side: .right): AngleRange(min: 150, max: 210),
                        .shoulder(side: .right): AngleRange(min: 140, max: 210)
                    ]
                ],
                description: "Extend one arm overhead in snatch position"
            )
        ]
        
        // Define the required QuickPose features for range of motion tracking
        // Create custom styles for overlay
        let lightOverlayStyle = QuickPose.Style(relativeFontSize: 0.0, relativeArcSize: 0.0, relativeLineWidth: 1.0)
        let noOverlayStyle = QuickPose.Style(relativeFontSize: 0.0, relativeArcSize: 0.0, relativeLineWidth: 0.0)
        
        let requiredFeatures: [QuickPose.Feature] = [
            // Shoulder tracking - Right shoulder CW (true), Left shoulder ACW (false)
            .rangeOfMotion(.shoulder(side: .right, clockwiseDirection: true), style: noOverlayStyle),
            .rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false), style: noOverlayStyle),
            // Elbow tracking - Right elbow ACW (false), Left elbow CW (true)
            .rangeOfMotion(.elbow(side: .right, clockwiseDirection: false), style: noOverlayStyle),
            .rangeOfMotion(.elbow(side: .left, clockwiseDirection: true), style: noOverlayStyle),
            // Note: Landmarks (wrist, hip, knee) are returned by default - no need to explicitly request them
            .overlay(.wholeBody, style: lightOverlayStyle) // Light body outline
        ]
        
        return CustomExercise(
            id: "standing_kettlebell_snatch",
            name: "Standing Kettlebell Snatch",
            description: "Explosive movement from arm at side to full overhead extension, simulating a kettlebell snatch to build power and shoulder strength.",
            stages: stages,
            requiredFeatures: requiredFeatures,
            hideFeedback: hideFeedback,
            showAOI: showAOI
        )
    }
}

