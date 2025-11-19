//
//  SideTiltsExercise.swift
//  FitCount
//
//  Created by QuickPose.ai
//

import Foundation
import QuickPoseCore

// MARK: - Side Tilts Exercise Definition
class SideTiltsExercise {
    static func createExercise(hideFeedback: Bool = false) -> CustomExercise {
        let stages = [
            // Stage 1: Start Position - Elbows Bent
            ExerciseStage(
                id: "start_position",
                name: "Center Position",
                requirements: [
                    .elbow(side: .left): AngleRange(min: 70, max: 200),
                    .elbow(side: .right): AngleRange(min: 70, max: 200),
                    .knee(side: .left): AngleRange(min: 160, max: 200),
                    .knee(side: .right): AngleRange(min: 160, max: 200),
                    .shoulder(side: .left): AngleRange(min: 0, max: 90),
                    .shoulder(side: .right): AngleRange(min: 0, max: 90)
                ],
                description: "Stand upright with both elbows bent and arms at your sides"
            ),
            
            // Stage 2: Right Arm Straight, Left Arm Bent
//            ExerciseStage(
//                id: "right_arm_straight",
//                name: "Straighten Right Arm",
//                requirements: [
//                    .elbow(side: .left): AngleRange(min: 70, max: 150),
//                    .elbow(side: .right): AngleRange(min: 160, max: 200),
//                    .shoulder(side: .left): AngleRange(min: 30, max: 70),
//                    .shoulder(side: .right): AngleRange(min: 0, max: 90)
//                ],
//                description: "Straighten your right arm while keeping left arm bent"
//            ),
            
            // Stage 3: Raising Right Arm (Midway)
            ExerciseStage(
                id: "raising_right_arm",
                name: "Raise Right Arm",
                requirements: [
                    .elbow(side: .left): AngleRange(min: 70, max: 150),
                    .elbow(side: .right): AngleRange(min: 120, max: 200),
                    .shoulder(side: .left): AngleRange(min: 30, max: 70),
                    .shoulder(side: .right): AngleRange(min: 75, max: 160)
                ],
                description: "Raise your right arm higher while maintaining left arm position"
            ),
            
            // Stage 4: Right Arm Leaning
            ExerciseStage(
                id: "right_arm_leaning",
                name: "Lean Right",
                requirements: [
                    .elbow(side: .left): AngleRange(min: 70, max: 150),
                    .elbow(side: .right): AngleRange(min: 120, max: 180),
                    .shoulder(side: .left): AngleRange(min: 10, max: 50),
                    .shoulder(side: .right): AngleRange(min: 160, max: 200),
                    .hip(side: .left): AngleRange(min: 180, max: 220),
                    .hip(side: .right): AngleRange(min: 170, max: 210)
                ],
                description: "Lean to the right with full right arm extension"
            ),
            
            // Stage 5: Return to Both Elbows Bent
            ExerciseStage(
                id: "return_to_center",
                name: "Return to Center",
                requirements: [
                    .elbow(side: .left): AngleRange(min: 70, max: 200),
                    .elbow(side: .right): AngleRange(min: 70, max: 200),
                    .knee(side: .left): AngleRange(min: 160, max: 200),
                    .knee(side: .right): AngleRange(min: 160, max: 200),
                    .shoulder(side: .left): AngleRange(min: 0, max: 90),
                    .shoulder(side: .right): AngleRange(min: 0, max: 90)
                ],
                description: "Return to center position with both elbows bent"
            ),
            
            // Stage 6: Left Arm Straight, Right Arm Bent
//            ExerciseStage(
//                id: "left_arm_straight",
//                name: "Straighten Left Arm",
//                requirements: [
//                    .elbow(side: .left): AngleRange(min: 160, max: 200),
//                    .elbow(side: .right): AngleRange(min: 140, max: 240),
//                    .shoulder(side: .left): AngleRange(min: 0, max: 70),
//                    .shoulder(side: .right): AngleRange(min: 0, max: 120)
//                ],
//                description: "Straighten your left arm while keeping right arm bent"
//            ),
            
            // Stage 7: Raising Left Arm (Midway)
            ExerciseStage(
                id: "raising_left_arm",
                name: "Raise Left Arm",
                requirements: [
                    .elbow(side: .left): AngleRange(min: 120, max: 200),
                    .elbow(side: .right): AngleRange(min: 140, max: 240),
                    .shoulder(side: .left): AngleRange(min: 60, max: 150),
                    .shoulder(side: .right): AngleRange(min: 0, max: 120)
                ],
                description: "Raise your left arm higher while maintaining right arm position"
            ),
            
            // Stage 8: Left Arm Leaning
            ExerciseStage(
                id: "left_arm_leaning",
                name: "Lean Left",
                requirements: [
                    .elbow(side: .left): AngleRange(min: 160, max: 220),
                    .elbow(side: .right): AngleRange(min: 160, max: 260),
                    .shoulder(side: .left): AngleRange(min: 170, max: 210),
                    .shoulder(side: .right): AngleRange(min: 0, max: 120),
                    .hip(side: .left): AngleRange(min: 120, max: 180),
                    .hip(side: .right): AngleRange(min: 100, max: 190)
                ],
                description: "Lean to the left with full left arm extension"
            )
        ]
        
        // Define the required QuickPose features for range of motion tracking
        // Using simplified approach - request standard measurements for all joints
        
        // Create custom styles for overlay
        let lightOverlayStyle = QuickPose.Style(relativeFontSize: 0.0, relativeArcSize: 0.0, relativeLineWidth: 1.0)
        let noOverlayStyle = QuickPose.Style(relativeFontSize: 0.0, relativeArcSize: 0.0, relativeLineWidth: 0.0)
        
        let requiredFeatures: [QuickPose.Feature] = [
            .rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false), style: lightOverlayStyle),
            .rangeOfMotion(.shoulder(side: .right, clockwiseDirection: true), style: lightOverlayStyle),
            .rangeOfMotion(.elbow(side: .left, clockwiseDirection: true), style: lightOverlayStyle),
            .rangeOfMotion(.elbow(side: .right, clockwiseDirection: true), style: lightOverlayStyle),
            .rangeOfMotion(.knee(side: .left, clockwiseDirection: true), style: lightOverlayStyle),
            .rangeOfMotion(.knee(side: .right, clockwiseDirection: true), style: lightOverlayStyle),
            .rangeOfMotion(.hip(side: .left, clockwiseDirection: true), style: lightOverlayStyle),
            .rangeOfMotion(.hip(side: .right, clockwiseDirection: true), style: lightOverlayStyle),
            .overlay(.wholeBody, style: noOverlayStyle) // Light body outline
        ]
        
        return CustomExercise(
            id: "side_tilts",
            name: "Side Tilts",
            description: "Lean from side to side with alternating arm movements to engage your core and improve lateral flexibility.",
            stages: stages,
            requiredFeatures: requiredFeatures,
            hideFeedback: hideFeedback
        )
    }
}
