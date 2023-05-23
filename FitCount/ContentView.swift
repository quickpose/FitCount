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
                
                // Replace with your grid of exercises
                // For example:
                Grid(exercises) { exercise in
                    ExerciseItemView(exercise: exercise)
                }
                .padding()
                //                .background(Color(#colorLiteral(red: 0.3254901961, green: 0.4431372549, blue: 1, alpha: 1)))
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
                    .foregroundColor(.white) // Set text color to white
            }
            .padding()
            .background(Color(#colorLiteral(red: 0.3254901961, green: 0.4431372549, blue: 1, alpha: 1))) // Set background color to the main color
            .cornerRadius(8) // Add corner radius for a rounded look
        }
    }
}

struct Grid<Item, ItemView>: View where Item: Identifiable, ItemView: View {
    private var items: [Item]
    private var viewForItem: (Item) -> ItemView
    
    init(_ items: [Item], viewForItem: @escaping (Item) -> ItemView) {
        self.items = items
        self.viewForItem = viewForItem
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                ForEach(items) { item in
                    viewForItem(item)
                }
            }
        }
    }
}
