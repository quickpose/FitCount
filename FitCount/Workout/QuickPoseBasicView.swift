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
}

class SessionData: ObservableObject {
    @Published var count = 0
    @Published var seconds = 0
}

enum WorkoutState {
    case volume
    case instructions
    case bbox
    case exercise
}

struct QuickPoseBasicView: View {
    private var quickPose = QuickPose(sdkKey: "01H122Z3J6NY33V548V2D55K3J") // register for your free key at https://dev.quickpose.ai
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var sessionConfig: SessionConfig
    
    private var exercise: Exercise
    
    @State private var overlayImage: UIImage?
    
    @State private var feedbackText: String? = nil
    
    @State var counter = QuickPoseThresholdCounter()
    @State var measure: Double = 0
    @State var count: Int = 0
    @State var seconds: Int = 0
    let exerciseTimer = TimerManager()
    
    @State var isInBBox = false
    @State var state = WorkoutState.volume
    
    @State private var indicatorWidth: CGFloat = 0.0
    
    @StateObject var sessionData = SessionData()
    
    @State var countScale = 1.0
    
    @State private var isActive: Bool = false
    
    let bboxTimer = TimerManager()
    
    init(exercise: Exercise) {
        self.exercise = exercise
    }
    
    func goToResults() {
        DispatchQueue.main.async {
            sessionData.seconds = Int(exerciseTimer.getTotalSeconds())
            sessionData.count = Int(counter.getCount())
            
            isActive = true // Set the state variable to trigger the navigation
        }
    }
    
    var body: some View {
        VStack{
            NavigationLink(value: "Workout results") {
                EmptyView()
            }.navigationDestination(isPresented: $isActive) {
                WorkoutResultsView()
                    .environmentObject(sessionData)
                    .environmentObject(viewModel)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    QuickPoseCameraView(useFrontCamera: true, delegate: quickPose)
                    QuickPoseOverlayView(overlayImage: $overlayImage)
                }
                .frame(width: geometry.safeAreaInsets.leading + geometry.size.width + geometry.safeAreaInsets.trailing)
                .edgesIgnoringSafeArea(.all)
                .overlay() {
                    if (state == WorkoutState.volume) {
                        VolumeChangeView().overlay(alignment: .bottom) {
                            Button (action: {
                                state = WorkoutState.bbox
                                VoiceCommands.standInsideBBox.say()
                            }) {
                                Text("Continue").foregroundColor(.white)
                                    .padding()
                                    .background(.indigo) // Set background color to the main color
                                    .cornerRadius(8) // Add corner radius for a rounded look
                            }
                        }
                    }
                    
                    if (state == WorkoutState.bbox) {
                        BoundingBoxView(isInBBox: isInBBox, indicatorWidth: indicatorWidth)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Button(action: {
                        goToResults()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.indigo)
                    }
                    .padding()
                }
                
                .overlay(alignment: .bottom) {
                    if (state == WorkoutState.exercise) {
                        HStack {
                            Text(String(count) + (sessionConfig.useReps ? " \\ " + String(sessionConfig.nReps) : "") + " reps")
                                .font(.system(size: 30, weight: .semibold))
                                .padding(16)
                                .scaleEffect(countScale)
                            
                            Text(String(seconds) + (!sessionConfig.useReps ? " \\ " + String(sessionConfig.nSeconds + sessionConfig.nMinutes * 60) : "") + " sec")
                                .font(.system(size: 30, weight: .semibold))
                                .padding(16)
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(.indigo)
                    }
                }
                .overlay(alignment: .center) {
                    if (state == WorkoutState.exercise) {
                        if let feedbackText = feedbackText {
                            Text(feedbackText)
                                .font(.system(size: 26, weight: .semibold)).foregroundColor(.white)
                                .padding(16)
                        }
                    }
                }
                .onAppear {
                    quickPose.start(features: exercise.features, onFrame: { status, image, features, feedback, landmarks in
                        
                        
                        
                        let width = geometry.size.width * 0.6
                        let height = geometry.size.height * 0.8
                        let x0 = geometry.size.width / 2
                        let y0 = geometry.size.height / 2
                        
                        // all xs in [x0 - (width/2), x0 + (width/2)]
                        // all ys in [y0 - (height/2), y0 + (height/2)]
                        
                        let scaleToView = CGAffineTransform(scaleX: geometry.size.width, y:geometry.size.height)
                        
                        if (state == WorkoutState.bbox && landmarks != nil) {
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
                            bboxTimer.pause()
                            bboxTimer.reset()
                            
                            state = WorkoutState.exercise
                        }
                        
                        if (state == WorkoutState.exercise && !exerciseTimer.isRunning()) {
                            Text2Speech(text: "Now let's start the \(exercise.name) exercise").say()
                            exerciseTimer.start()
                        }
                        
                        if (state == WorkoutState.exercise) {
                            seconds = Int(exerciseTimer.getTotalSeconds())
                            
                            if let feedback = feedback[.fitness(.bicepsCurls)] {
                                feedbackText = feedback.displayString
                            } else {
                                feedbackText = nil
                            }
                            
                            if case .fitness = exercise.features.first, let result = features[exercise.features.first!]{
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
                                
                                if (sessionConfig.useReps && count >= sessionConfig.nReps || !sessionConfig.useReps && Int(exerciseTimer.getTotalSeconds()) >= (sessionConfig.nSeconds + sessionConfig.nMinutes * 60)) {
                                    goToResults()
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
                }.onAppear() {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                .onDisappear {
                    let sessionDataDump = SessionDataModel(exercise: exercise.name, count: Int(counter.getCount()), seconds: Int(exerciseTimer.getTotalSeconds()), date: Date())
                    appendToJson(sessionData: sessionDataDump)
                    
                    quickPose.stop()
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}
