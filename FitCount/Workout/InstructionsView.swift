//
//  InstructionsView.swift
//  FitCounter
//
//  Created by QuickPose.ai on 02.06.2023.
//

import SwiftUI

struct InstructionsView: View {
    var body: some View {
        VStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
                .overlay(
                    VStack (spacing: 30){
                        Image("instructionImage")
                                    .resizable()
                                    .scaledToFit()
                        
                        Text("Instructions")
                            .font(.title)
                            .multilineTextAlignment(.center)
                        Text("1. Place your phone on the floor against the wall\n 2. Press Start button and stand so your whole body is inside the bounding box\n3. Follow voice commands")
                            .font(.body)
                            .multilineTextAlignment(.center)
                        
                    }.frame(width: 300)
                )
        }
    
    }
}
