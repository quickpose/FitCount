//
//  HistoryView.swift
//  FitCount
//
//  Created by QuickPose.ai on 29.05.2023.
//

import SwiftUI

struct HistoryView: View {
    let sessionDataArray: [SessionDataModel]?
    
    init() {
        self.sessionDataArray = loadAndDisplayJsonData()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let sessionDataArray = sessionDataArray {
                    ScrollView {
                        ForEach(sessionDataArray.reversed(), id: \.self) { sessionData in
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(sessionData.exercise)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("AccentColor"))
                                    
                                    Text(sessionData.date.formatted(
                                        .dateTime
                                            .day(.defaultDigits)
                                            .month(.abbreviated)
                                            .year(.defaultDigits)
                                    ))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("\(sessionData.count) reps")
                                        .font(.title2)
                                    
                                    Text("\(sessionData.seconds) sec")
                                        .font(.title2)
                                    
                                    
                                }
                            }
                            
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .cornerRadius(8)
                            Divider()
                        }
                    }
                    .padding(.horizontal, 16)
                } else {
                    Text("No data to display.")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(16)
                }
            }
            .navigationBarTitle("History")
        }
        
    }
}
