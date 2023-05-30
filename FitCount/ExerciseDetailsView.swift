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
                .foregroundColor(Color.gray)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}


struct ExerciseDetailsView: View {
    let exercise: Exercise
    
    @State private var nReps : Int = 1
    @State private var nMinutes : Int = 1
    @State private var nSeconds: Int = 0
    
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
                        .foregroundColor(.black)
                        .padding(.top, 8)
                    
                    Picker("Reps", selection: $nReps) {
                        ForEach(1...100, id: \.self) { number in
                            Text("\(number) reps")
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
                .pagerTabItem(tag: 1) {
                    TitleNavBarItem(title: "Reps")
                }
                
                VStack {
                    Text("Select the time of the exercise")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top, 8)
                    
                    HStack{
                        
                        Picker("Minutes", selection: $nMinutes) {
                            ForEach(0...30, id: \.self) { number in
                                Text("\(number) min")
                                    .foregroundColor(.black)
                            }
                        }
                        .onChange(of: nMinutes) { min in
                            // make sure that time is not 0
                            if (min <= 0 && nSeconds <= 0) {
                                nMinutes = 0
                                nSeconds = 1
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        
                        Picker("Seconds", selection: $nSeconds) {
                            ForEach(0...59, id: \.self) { number in
                                Text("\(number) sec")
                                    .foregroundColor(.black)
                            }
                        }
                        .onChange(of: nSeconds) { sec in
                            // make sure that time is not 0
                            if (nMinutes <= 0 && sec <= 0) {
                                nMinutes = 1
                                nSeconds = 0
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        
                    }
                    
                }
                .clipped()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                .padding().pagerTabItem(tag: 2) {
                    TitleNavBarItem(title: "Timer")
                }
            }
            
            
            
            NavigationLink(destination: WorkoutView(nReps: selection == 1 ? nReps : nil, nSeconds: selection == 2 ? nMinutes * 60 + nSeconds : nil)) {
                Text("Start workout")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(#colorLiteral(red: 0.3254901961, green: 0.4431372549, blue: 1, alpha: 1))) // Set background color to the main color
                    .cornerRadius(8) // Add corner radius for a rounded look
            }
            
            
        }
        .navigationBarTitle(Text(exercise.name))
        
    }
}

//struct ExerciseDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExerciseDetailsView(exercise: Exercise(name: "Exercise 1", details: "Exercise 1 details"))
//    }
//}
