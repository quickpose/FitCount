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

struct QuickPoseBasicView: View {
    private var quickPose = QuickPose(sdkKey: "01H122Z3J6NY33V548V2D55K3J") // register for your free key at https://
    let synthesizer = AVSpeechSynthesizer()
    @State private var overlayImage: UIImage?
    
    @State private var feedbackText: String? = nil
    
    @State var counter = QuickPoseThresholdCounter()
    @State var measure: Double = 0
    @State var count: Int = 0
    
    @State var isInBBox = false
    @State var showBbox = true
    
    @State private var indicatorWidth: CGFloat = 0.0
    
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        synthesizer.speak(utterance)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                QuickPoseCameraView(useFrontCamera: true, delegate: quickPose)
                QuickPoseOverlayView(overlayImage: $overlayImage)
            }
            .overlay(alignment: .center) {
                if let feedbackText = feedbackText {
                    Text(feedbackText)
                        .font(.system(size: 26, weight: .semibold)).foregroundColor(.white)
                        .padding(16)
                }
            }
            .frame(width: geometry.safeAreaInsets.leading + geometry.size.width + geometry.safeAreaInsets.trailing)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                GeometryReader { geometry in
                    VStack {
                        Rectangle()
                            .stroke(isInBBox ? Color.green : Color.red, lineWidth: 5)
                            .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.8)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                    
                }
            )
            .overlay(alignment: .bottom) {
                Text("Reps: " + String(count))
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .onAppear {
                quickPose.start(features: [.fitness(.bicepsCurls), .overlay(.wholeBody)], onFrame: { status, image, features,  feedback, landmarks in
                    
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
                    
                    if let feedback = feedback[.fitness(.bicepsCurls)] {
                        feedbackText = feedback.displayString
                    } else {
                        feedbackText = nil
                    }
                    
                    if let result = features[.fitness(.bicepsCurls)]{
                        counter.count(probability: result.value)
                        count = counter.getCount()
                        measure = result.value
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

struct QuickPoseBasicView_Previews: PreviewProvider {
    static var previews: some View {
        QuickPoseBasicView()
    }
}
