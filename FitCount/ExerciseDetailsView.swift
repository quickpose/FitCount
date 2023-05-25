//
//  ExerciseDetailsView.swift
//  FitCount
//
//  Created by QuickPose.ai on 22.05.2023.
//

import SwiftUI

struct ExerciseDetailsView: View {
    let exercise: Exercise
    
    @State private var nReps = 1
    
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
            
            HStack {
                Text("Number of reps:")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.trailing, 8)
                
                Picker("Number of reps", selection: $nReps) {
                    ForEach(1...100, id: \.self) { number in
                        Text("\(number)")
                            .foregroundColor(.black)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                
            }
            .clipped()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            .padding()
            
            NavigationLink(destination: WorkoutView(nReps: nReps)) {
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
