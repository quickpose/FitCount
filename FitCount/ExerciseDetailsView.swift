//
//  ExerciseDetailsView.swift
//  FitCount
//
//  Created by QuickPose.ai on 22.05.2023.
//

import SwiftUI

struct ExerciseDetailsView: View {
    let exercise: Exercise
    
    var body: some View {
        VStack {
            Text(exercise.name)
                .font(.title)
                .padding()
            
            Text(exercise.details)
                .font(.body)
                .padding()
            
            
            
            // Add more exercise details as needed
            
            Spacer()
            
            NavigationLink(destination: WorkoutView()) {
                Text("Start workout")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(#colorLiteral(red: 0.3254901961, green: 0.4431372549, blue: 1, alpha: 1))) // Set background color to the main color
                    .cornerRadius(8) // Add corner radius for a rounded look
            }
            
            
        }
        .navigationBarTitle(Text("Exercise Details"))
        
    }
}

struct ExerciseDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailsView(exercise: Exercise(name: "Exercise 1", details: "Exercise 1 details"))
    }
}
