//
//  QuickPoseBasicView.swift
//  FitCount
//
//  Created by QuickPose.ai on 22.05.2023.
//

import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI

struct VoiceCommands {
    public static let standInsideBBox = Text2Speech(text: "Stand so that your whole body is inside the bounding box")
    public static let letUsStartTheExercise = Text2Speech(text: "Now let's start the exercise")
}

struct QuickPoseBasicView: View {
    private var quickPose = QuickPose(sdkKey: "01H122Z3J6NY33V548V2D55K3J") // register for your free key at https://dev.quickpose.ai
    private var nReps: Int
    
    @State private var overlayImage: UIImage?
    
    @State private var feedbackText: String? = nil
    
    @State var counter = QuickPoseThresholdCounter()
    @State var measure: Double = 0
    @State var count: Int = 0
    
    @State var isInBBox = false
    @State var isBBoxState = true
    
    @State private var indicatorWidth: CGFloat = 0.0
    
    
    @State var countScale = 1.0
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isActive: Bool = false
    
    let bboxTimer = TimerManager()
    
    init(nReps: Int) {
        self.nReps = nReps
    }
    
    var body: some View {
        VStack{
            NavigationLink(
                destination: WorkoutResultsView(), isActive: $isActive) {
                    EmptyView()
                }.navigationBarBackButtonHidden(true)
            
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    QuickPoseCameraView(useFrontCamera: true, delegate: quickPose)
                    QuickPoseOverlayView(overlayImage: $overlayImage)
                }
                .frame(width: geometry.safeAreaInsets.leading + geometry.size.width + geometry.safeAreaInsets.trailing)
                .edgesIgnoringSafeArea(.all)
                .overlay() {
                    if (isBBoxState) {
                        BoundingBoxView(isInBBox: isInBBox, indicatorWidth: indicatorWidth)
                    }
                }
                .overlay(alignment: .bottom) {
                    if (!isBBoxState) {
                        Text("Reps: " + String(count))
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .scaleEffect(countScale)
                    }
                }
                .overlay(alignment: .center) {
                    if (!isBBoxState) {
                        if let feedbackText = feedbackText {
                            Text(feedbackText)
                                .font(.system(size: 26, weight: .semibold)).foregroundColor(.white)
                                .padding(16)
                        }
                    }
                }
                .onAppear {
                    quickPose.start(features: [.fitness(.bicepsCurls), .overlay(.wholeBody)], onFrame: { status, image, features,  feedback, landmarks in
                        
                        VoiceCommands.standInsideBBox.say()
                        
                        let width = geometry.size.width * 0.6
                        let height = geometry.size.height * 0.8
                        let x0 = geometry.size.width / 2
                        let y0 = geometry.size.height / 2
                        
                        // all xs in [x0 - (width/2), x0 + (width/2)]
                        // all ys in [y0 - (height/2), y0 + (height/2)]
                        
                        let scaleToView = CGAffineTransform(scaleX: geometry.size.width, y:geometry.size.height)
                        
                        if (landmarks != nil) {
                            let scaledLandmarks = landmarks!.poseLandmarks.map {
                                let point = CGPoint(x: $0[0], y: $0[1]).applying(scaleToView)
                                return [point.x, point.y, $0[2]]
                            }
                            
                            let xsInBox = scaledLandmarks.allSatisfy { x0 - (width/2) < $0[0] && $0[0] < x0 + (width/2) }
                            let ysInBox = scaledLandmarks.allSatisfy { y0 - (height/2) < $0[1] && $0[1] < y0 + (height/2) }
                            
                            isInBBox = xsInBox && ysInBox
                        }
                        
                        if (!isInBBox && bboxTimer.isRunning()) {
                            bboxTimer.pause()
                            bboxTimer.reset()
                            indicatorWidth = 0
                        }
                        
                        if (isInBBox && !bboxTimer.isRunning()) {
                            bboxTimer.start()
                        }
                        
                        if (bboxTimer.isRunning()) {
                            indicatorWidth = bboxTimer.getTotalSeconds() / 2
                        }
                        
                        if (bboxTimer.isRunning() && bboxTimer.getTotalSeconds() > 2) {
                            isBBoxState = false
                            VoiceCommands.letUsStartTheExercise.say()
                        }
                        
                        if (!isBBoxState) {
                            if let feedback = feedback[.fitness(.bicepsCurls)] {
                                feedbackText = feedback.displayString
                            } else {
                                feedbackText = nil
                            }
                            
                            if let result = features[.fitness(.bicepsCurls)]{
                                counter.count(probability: result.value)
                                if (counter.getCount() > count) {
                                    Text2Speech(text: String(counter.getCount())).say()
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        countScale = 2.0
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            countScale = 1.0
                                        }
                                    }
                                }
                                count = counter.getCount()
                                
                                if (count >= nReps) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        isActive = true // Set the state variable to trigger the navigation
                                    }
                                }
                                
                                measure = result.value
                            }
                        }
                        if case .success(_,_) = status {
                            overlayImage = image
                        } else {
                            overlayImage = nil
                        }
                    })
                }.onDisappear {
                    quickPose.stop()
                }
            }
        }
    }
}
