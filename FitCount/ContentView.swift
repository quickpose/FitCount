//
//  ContentView.swift
//  FitCount
//
//  Created by QuickPose.ai on 22.05.2023.
//

import SwiftUI


class SessionConfig: ObservableObject {
    @Published var nReps : Int = 1
    @Published var nMinutes : Int = 0
    @Published var nSeconds : Int = 1
    @Published var useReps: Bool = true
    @Published var exercise: Exercise = exercises[0] // use first exercise by default but change in the ExerciseDetailsView
}

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    @StateObject var sessionConfig = SessionConfig()
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            TabView{
                VStack {
                    List(exercises) { exercise in
                        NavigationLink(value: exercise) {
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                    .font(.headline)
                            }
                            .padding()
                            .cornerRadius(8)
                        }
                    }
                    .background(.white)
                }.navigationBarTitle(Text("Workouts"))
                .tabItem{
                    Label("Exercises", systemImage: "figure.strengthtraining.functional")
                }
                
                HistoryView().tabItem{
                    Label("History", systemImage: "chart.bar")
                }
                
                AboutView().tabItem{
                    Label("About", systemImage: "info.square")
                }
            }
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailsView(exercise: exercise)
                    .environmentObject(viewModel)
                    .environmentObject(sessionConfig)
            }
            .navigationDestination(for: String.self) { value in
                if value == "Workout" {
                    WorkoutView().environmentObject(viewModel).environmentObject(sessionConfig)
                }
            }
        }
    }
}


class ViewModel: ObservableObject {
    @Published var path = NavigationPath()
    
    func popToRoot(){
        path.removeLast(path.count) // pop to root
    }
}
