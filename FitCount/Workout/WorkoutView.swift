//
//  WorkoutView.swift
//  FitCount
//
//  Created by QuickPose.ai on 22.05.2023.
//

import SwiftUI
import AVFoundation

struct WorkoutView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @State var cameraPermissionGranted = false
    var exercise: Exercise
    var nReps: Int?
    var nSeconds: Int?
    
    
    var body: some View {
        GeometryReader { geometry in
            if cameraPermissionGranted {
                QuickPoseBasicView(exercise: exercise, nReps: nReps, nSeconds: nSeconds).environmentObject(viewModel)
            }
        }.onAppear {
            AVCaptureDevice.requestAccess(for: .video) { accessGranted in
                DispatchQueue.main.async {
                    self.cameraPermissionGranted = accessGranted
                }
            }
        }
    }
}
