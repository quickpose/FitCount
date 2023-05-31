//
//  ContentView.swift
//  FitCount
//
//  Created by QuickPose.ai on 22.05.2023.
//

import SwiftUI

struct ContentView: View {
    @State var viewModel = ViewModel()
    
    let sessionDataArray = loadAndDisplayJsonData()
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            TabView{
                NavigationView {
                    VStack {
                        List(exercises) { exercise in
                            ExerciseItemView(exercise: exercise)
                        }
                        .background(.white)
                    }.navigationBarTitle(Text("Workouts"))
                }.tabItem{
                    Label("Exercises", systemImage: "figure.strengthtraining.functional")
                }
                
                HistoryView(sessionDataArray: sessionDataArray).tabItem{
                    Label("History", systemImage: "chart.bar")
                }
            }
        }
    }
}


struct ExerciseItemView: View {
//    @Binding var path: [Int]
    let exercise: Exercise
    
    var body: some View {
//        NavigationLink() {}
//            .navigationDestination(for: Exercise.self) { exercise in
//                ExerciseDetailsView(exercise: exercise)
//            }
        
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

class ViewModel: ObservableObject {
    @Published var path:NavigationPath = NavigationPath()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


