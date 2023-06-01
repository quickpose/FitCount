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
            VStack(spacing: 20) {
                Text("Your workour results")
                    .font(.largeTitle)
                    .padding(.top, 50)
                
                Text("Number of reps: \(sessionData.count)")
                    .font(.title2)
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
            .navigationBarBackButtonHidden(true)
//            .navigationBarTitle("Results")
            .padding()
            .background(Color.white)
        }
    }
}
