//
//  ContentView.swift
//  FitCount
//
//  Created by QuickPose.ai on 22.05.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            TabView{
                NavigationView {
                    VStack {
                        List(exercises) { exercise in
                            NavigationLink(value: exercise) {
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                        .font(.headline)
                                }
                                .padding()
                                .cornerRadius(8) // Add corner radius for a rounded look
                            }.navigationDestination(for: Exercise.self) { exercise in
                                ExerciseDetailsView(exercise: exercise).environmentObject(viewModel)
                            }
                        }
                        .background(.white)
                    }.navigationBarTitle(Text("Workouts"))
                }
                    .tabItem{
                        Label("Exercises", systemImage: "figure.strengthtraining.functional")
                    }
                
                HistoryView().tabItem{
                    Label("History", systemImage: "chart.bar")
                }
            }
        }
    }
}


class ViewModel: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


