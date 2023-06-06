//
//  ExerciseDetailsView.swift
//  FitCount
//
//  Created by QuickPose.ai on 22.05.2023.
//

import SwiftUI
import PagerTabStripView

struct TitleNavBarItem: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ExerciseDetailsView: View {
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var sessionConfig: SessionConfig
    
    let exercise: Exercise
    
    @State var selection = 1
    
    var body: some View {
        VStack {
            
            Text(exercise.details)
                .font(.body)
                .padding()
            
            Spacer()
            
            PagerTabStripView(
                swipeGestureEnabled: .constant(false),
                selection: $selection
            ) {
                VStack {
                    Text("Select the number of reps")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    Picker("Reps", selection: $sessionConfig.nReps) {
                        ForEach(1...100, id: \.self) { number in
                            Text("\(number) reps")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                .clipped()
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                .padding()
                .pagerTabItem(tag: 1) {
                    TitleNavBarItem(title: "Reps")
                }
                
                VStack {
                    Text("Select the time of the exercise")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    HStack{
                        
                        Picker("Minutes", selection: $sessionConfig.nMinutes) {
                            ForEach(0...30, id: \.self) { number in
                                Text("\(number) min")
                            }
                        }
                        .onChange(of: sessionConfig.nMinutes) { min in
                            // make sure that time is not 0
                            if (min <= 0 && sessionConfig.nSeconds <= 0) {
                                sessionConfig.nMinutes = 0
                                sessionConfig.nSeconds = 1
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        
                        Picker("Seconds", selection: $sessionConfig.nSeconds) {
                            ForEach(0...59, id: \.self) { number in
                                Text("\(number) sec")
                            }
                        }
                        .onChange(of: sessionConfig.nSeconds) { sec in
                            // make sure that time is not 0
                            if (sessionConfig.nMinutes <= 0 && sec <= 0) {
                                sessionConfig.nMinutes = 1
                                sessionConfig.nSeconds = 0
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        
                    }
                    
                }
                .clipped()
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                .padding()
                .pagerTabItem(tag: 2) {
                    TitleNavBarItem(title: "Timer")
                }
            }
            .onChange(of: selection) { newValue in
                sessionConfig.useReps = newValue == 1
            }
            
            NavigationLink(value: "Workout") {
                Text("Start workout")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("AccentColor"))
                    .cornerRadius(8)
                
            }
            .navigationDestination(for: String.self) { _ in
                WorkoutView().environmentObject(viewModel).environmentObject(sessionConfig)
            }
            
            
        }
        .navigationBarTitle(Text(exercise.name))
        .onAppear() {
            sessionConfig.exercise = exercise
            sessionConfig.useReps = selection == 1
        }
    }
}
