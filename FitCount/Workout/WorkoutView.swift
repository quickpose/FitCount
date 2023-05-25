//
//  WorkoutView.swift
//  FitCount
//
//  Created by QuickPose.ai on 22.05.2023.
//

import SwiftUI
import AVFoundation

struct WorkoutView: View {
    @State var cameraPermissionGranted = false
    var nReps: Int
    
    init(nReps: Int) {
        self.nReps = nReps
    }
    
    var body: some View {
        GeometryReader { geometry in
            if cameraPermissionGranted {
                QuickPoseBasicView(nReps: nReps)
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
