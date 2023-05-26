//
//  ContentView.swift
//  FitCount
//
//  Created by QuickPose.ai on 22.05.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                List(exercises) { exercise in
                    ExerciseItemView(exercise: exercise)
                }
                .background(.white)
            }.navigationBarTitle(Text("Workouts"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ExerciseItemView: View {
    let exercise: Exercise
    
    var body: some View {
        NavigationLink(destination: ExerciseDetailsView(exercise: exercise)) {
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.headline)
            }
            .padding()
            .cornerRadius(8) // Add corner radius for a rounded look
        }
    }
}
