//
//  WorkoutResults.swift
//  FitCount
//
//  Created by QuickPose.ai on 25.05.2023.
//

import SwiftUI

struct WorkoutResultsView: View {
    @EnvironmentObject var sessionData: SessionData
    
    var body: some View {
        VStack{
            
            Text("Count: " + String(sessionData.count))
            Text("Time: " + String(sessionData.seconds))
            
//            Button("Pop to Root") {
//
//            }
            
        }
        .navigationBarBackButtonHidden(true)
    }
}
