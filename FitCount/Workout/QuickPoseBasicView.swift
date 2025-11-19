//
//  QuickPoseBasicView.swift
//  FitCount
//
//  Created by QuickPose.ai on 22.05.2023.
//

import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI
import AVFoundation

struct SessionData: Equatable {
    let count: Int
    let seconds: Int
}

enum ViewState: Equatable {
    case startVolume
    case instructions
    case introBoundingBox
    case boundingBox(enterTime: Date)
    case introExercise(Exercise)
    case exercise(SessionData, enterTime: Date)
    case results(SessionData)
    
    var speechPrompt: String? {
        switch self {
        case .introBoundingBox:
            return "Stand so that your whole body is inside the bounding box"
        case .introExercise(let exercise):
            return "Now let's start the \(exercise.name) exercise"
        default:
            return nil
        }
    }
}

struct QuickPoseBasicView: View {
    private var quickPose = QuickPose(sdkKey: "ENTER YOUR SDK KEY HERE") // register for your free key at https://dev.quickpose.ai
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var sessionConfig: SessionConfig
    
    @State private var overlayImage: UIImage?
    @State private var feedbackText: String? = nil
    
    @State private var counter = QuickPoseThresholdCounter()
    @State private var customExerciseEngine: CustomExerciseEngine?
    @State private var state: ViewState = .startVolume
    
    @State private var boundingBoxVisibility = 1.0
    @State private var countScale = 1.0
    @State private var boundingBoxMaskWidth = 0.0
    
    static let synthesizer = AVSpeechSynthesizer()
    
    // Computed property to determine if feedback should be shown
    private var shouldShowFeedback: Bool {
        if sessionConfig.exercise.isCustomExercise {
            return !(customExerciseEngine?.exercise.hideFeedback ?? false)
        }
        return true
    }
    
    func canMoveFromBoundingBox(landmarks: QuickPose.Landmarks) -> Bool {
        let xsInBox = landmarks.allLandmarksForBody().allSatisfy { 0.5 - (0.8/2) < $0.x && $0.x < 0.5 + (0.8/2) }
        let ysInBox = landmarks.allLandmarksForBody().allSatisfy { 0.5 - (0.9/2) < $0.y && $0.y < 0.5 + (0.9/2) }
        
        return xsInBox && ysInBox
    }
    
    // Extract the feedback overlay into a separate function to avoid complex type checking
    @ViewBuilder
    private func feedbackOverlay(for feedbackText: String) -> some View {
        VStack {
            Spacer().frame(height: 60) // Add some top spacing
            
            // Determine colors based on feedback message
            let isCorrect = feedbackText.contains("✅")
            let isAdjustment = feedbackText.contains("🔴")
            let backgroundColor = isCorrect ? Color.green.opacity(0.8) : 
                                isAdjustment ? Color.red.opacity(0.8) : 
                                Color.black.opacity(0.8)
            let borderColor = isCorrect ? Color.green : 
                            isAdjustment ? Color.red : 
                            Color("AccentColor")
            
            Text(feedbackText)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(borderColor, lineWidth: 2)
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            Spacer()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack(alignment: .top) {
                    QuickPoseCameraView(useFrontCamera: true, delegate: quickPose)
                    QuickPoseOverlayView(overlayImage: $overlayImage)
                }
                .frame(width: geometry.safeAreaInsets.leading + geometry.size.width + geometry.safeAreaInsets.trailing)
                .edgesIgnoringSafeArea(.all)
                .overlay() {
                    switch state {
                    case .startVolume:
                        VolumeChangeView()
                            .overlay(alignment: .bottom) {
                                Button (action: {
                                    state = .instructions
                                }) {
                                    Text("Continue").foregroundColor(.white)
                                        .padding()
                                        .background(Color("AccentColor"))
                                        .cornerRadius(8)
                                }
                            }
                    case .instructions:
                        InstructionsView()
                            .overlay(alignment: .bottom) {
                                Button (action: {
                                    state = .introBoundingBox
                                    Text2Speech(text: state.speechPrompt!).say()
                                }) {
                                    Text("Start Workout").foregroundColor(.white)
                                        .padding()
                                        .background(Color("AccentColor"))
                                        .cornerRadius(8)
                                }
                            }
                    case .introBoundingBox:
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.red, lineWidth: 5)
                        }
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.9)
                        .padding(.horizontal, (geometry.size.width * 1 - 0.8)/2)
                        
                    case .boundingBox:
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.green, lineWidth: 5)
                            
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.green.opacity(0.5))
                                .mask(alignment: .leading) {
                                    Rectangle()
                                        .frame(width: geometry.size.width * 0.9 * boundingBoxMaskWidth)
                                }
                        }
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.9)
                        .padding(.horizontal, (geometry.size.width * 1 - 0.8)/2)
                        
                        
                    case .results(let results):
                        WorkoutResultsView(sessionData: results)
                            .environmentObject(viewModel)
                        
                    default:
                        EmptyView()
                    }
                }
                
                .overlay(alignment: .topTrailing) {
                    Button(action: {
                        if case .results = state {
                            viewModel.popToRoot()
                        } else {
                            state = .results(SessionData(count: counter.state.count, seconds: 0))
                            quickPose.stop()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(Color("AccentColor"))
                    }
                    .padding()
                }
                
                .overlay(alignment: .bottom) {
                    if case .exercise(let results, let enterTime) = state {
                        HStack {
                            Text(String(results.count) + (sessionConfig.useReps ? " \\ " + String(sessionConfig.nReps) : "") + " reps")
                                .font(.system(size: 30, weight: .semibold))
                                .padding(16)
                                .scaleEffect(countScale)
                            
                            Text(String(format: "%.0f",-enterTime.timeIntervalSinceNow) + (!sessionConfig.useReps ? " \\ " + String(sessionConfig.nSeconds + sessionConfig.nMinutes * 60) : "") + " sec")
                                .font(.system(size: 30, weight: .semibold))
                                .padding(16)
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color("AccentColor"))
                    }
                }
                .overlay(alignment: .top) {
                    if case .exercise = state, let feedbackText = feedbackText, shouldShowFeedback {
                        feedbackOverlay(for: feedbackText)
                    }
                }
                
                .onChange(of: state) { _ in
                    if case .results(let result) = state {
                        do {
                            let sessionDataDump = SessionDataModel(exercise: sessionConfig.exercise.name, count: result.count, seconds: result.seconds, date: Date())
                            appendToJson(sessionData: sessionDataDump)
                        } catch {
                            print("Error saving session data: \(error.localizedDescription)")
                        }
                    } else {
                        // Only update features if we're not in the results state
                        do {
                            quickPose.update(features: sessionConfig.exercise.features)
                        } catch {
                            print("Error updating QuickPose features: \(error.localizedDescription)")
                        }
                    }
                }
                .onAppear() {
                    UIApplication.shared.isIdleTimerDisabled = true
                    DispatchQueue.main.asyncAfter(deadline: .now()+1.0){
                        quickPose.start(features: sessionConfig.exercise.features, onFrame: { status, image, features, feedback, landmarks in
                            overlayImage = image
                            if case .success = status {
                                
                                switch state {
                                case .introBoundingBox:
                                    
                                    if let landmarks = landmarks, canMoveFromBoundingBox(landmarks: landmarks) {
                                        state = .boundingBox(enterTime: Date())
                                        boundingBoxMaskWidth = 0
                                    }
                                case .boundingBox(let enterDate):
                                    if let landmarks = landmarks, canMoveFromBoundingBox(landmarks: landmarks) {
                                        let timeSinceInsideBBox = -enterDate.timeIntervalSinceNow
                                        boundingBoxMaskWidth = timeSinceInsideBBox / 2
                                        if timeSinceInsideBBox > 2 {
                                            state = .introExercise(sessionConfig.exercise)
                                        }
                                    } else {
                                        state = .introBoundingBox
                                    }
                                case .introExercise(_):
                                    // Initialize custom exercise engine if needed
                                    if sessionConfig.exercise.isCustomExercise {
                                        if sessionConfig.exercise.name == "Side Tilts" {
                                            customExerciseEngine = CustomExerciseEngine(exercise: SideTiltsExercise.createExercise())
                                        } else if sessionConfig.exercise.name == "Knee Raises" {
                                            customExerciseEngine = CustomExerciseEngine(exercise: KneeRaisesExercise.createExercise())
                                        } else if sessionConfig.exercise.name == "Front Push-up" {
                                            customExerciseEngine = CustomExerciseEngine(exercise: FrontPushupExercise.createExercise())
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                        state = .exercise(SessionData(count: 0, seconds: 0), enterTime: Date())
                                    }
                                case .exercise(_, let enterDate):
                                    let secondsElapsed = Int(-enterDate.timeIntervalSinceNow)
                                    
                                    var currentCount = 0
                                    
                                    if sessionConfig.exercise.isCustomExercise {
                                        // Handle custom exercises
                                        if let customEngine = customExerciseEngine {
                                            currentCount = customEngine.processFrame(features: features)
                                            feedbackText = customEngine.feedbackMessage
                                            
                                            // Handle rep completion feedback
                                            if customEngine.newRepCompleted {
                                                Text2Speech(text: "\(currentCount)").say()
                                                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                                    withAnimation(.easeInOut(duration: 0.1)) {
                                                        countScale = 2.0
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                                                        withAnimation(.easeInOut(duration: 0.2)) {
                                                            countScale = 1.0
                                                        }
                                                    }
                                                }
                                                customEngine.newRepCompleted = false // Reset the flag
                                            }
                                        }
                                    } else {
                                        // Handle built-in exercises
                                        if let feedback = feedback[sessionConfig.exercise.features.first!] {
                                            feedbackText = feedback.displayString
                                        } else {
                                            feedbackText = nil
                                            
                                            if case .fitness = sessionConfig.exercise.features.first, let result = features[sessionConfig.exercise.features.first!] {
                                                _ = counter.count(result.value) { newState in
                                                    if !newState.isEntered {
                                                        Text2Speech(text: "\(counter.state.count)").say()
                                                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                                countScale = 2.0
                                                            }
                                                            DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                                    countScale = 1.0
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        currentCount = counter.state.count
                                    }
                                    
                                    let newResults = SessionData(count: currentCount, seconds: secondsElapsed)
                                    state = .exercise(newResults, enterTime: enterDate) // refresh view for every updated second
                                    var hasFinished = false
                                    if sessionConfig.useReps {
                                        hasFinished = currentCount >= sessionConfig.nReps
                                    } else {
                                        hasFinished = secondsElapsed >= sessionConfig.nSeconds + sessionConfig.nMinutes * 60
                                    }
                                    
                                    if hasFinished {
                                        // Create a new SessionData object to avoid any potential reference issues
                                        let finalResults = SessionData(count: newResults.count, seconds: newResults.seconds)
                                        
                                        // First change the state, then stop QuickPose
                                        DispatchQueue.main.async {
                                            state = .results(finalResults)
                                            
                                            // Add a small delay before stopping QuickPose to ensure the state change is processed
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                // Safely stop QuickPose
                                                do {
                                                    quickPose.stop()
                                                } catch {
                                                    print("Error stopping QuickPose: \(error.localizedDescription)")
                                                }
                                            }
                                        }
                                    }
                                default:
                                    break
                                }
                            } else if state != .startVolume && state != .instructions{
                                state = .introBoundingBox
                            }
                        })
                    }
                }
                .onDisappear {
                    UIApplication.shared.isIdleTimerDisabled = false
                    
                    // Safely stop QuickPose when view disappears
                    DispatchQueue.main.async {
                        do {
                            quickPose.stop()
                        } catch {
                            print("Error stopping QuickPose on disappear: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar)
        }
    }
}
