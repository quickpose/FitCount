//
//  WorkoutResults.swift
//  FitCount
//
//  Created by QuickPose.ai on 25.05.2023.
//

import SwiftUI

struct WorkoutResultsView: View {
    @EnvironmentObject var sessionData: SessionData
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack{
            
            Text("Count: " + String(sessionData.count))
            Text("Time: " + String(sessionData.seconds))
            
            Button {
                viewModel.path.removeLast(viewModel.path.count)
            } label: {
                Text("Finish workout")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(#colorLiteral(red: 0.3254901961, green: 0.4431372549, blue: 1, alpha: 1))) // Set background color to the main color
                    .cornerRadius(8) // Add corner radius for a rounded look
            }.padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}
