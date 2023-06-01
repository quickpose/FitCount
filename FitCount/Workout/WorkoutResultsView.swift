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
        NavigationView{
            VStack() {
                Text("Number of reps: \(sessionData.count)")
                    .font(.title)
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                
                Text("Time: \(sessionData.seconds) Seconds")
                    .font(.title2)
                    .padding(.bottom, 40)
                
                Button(action: {
                    viewModel.path.removeLast(viewModel.path.count)
                }) {
                    Text("Finish Workout")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.indigo)
                        .cornerRadius(8)
                }
                .padding()
                .buttonStyle(PlainButtonStyle()) // Remove button style highlighting
                
                Spacer()
            }
            .navigationBarTitle("Results")
            .navigationBarBackButtonHidden(true)
            .padding()
            .background(Color.white) // Set the background color of the entire view
//            .padding([.leading, .trailing], 24)
        }
    }
}
