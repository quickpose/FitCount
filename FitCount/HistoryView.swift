//
//  HistoryView.swift
//  FitCount
//
//  Created by QuickPose.ai on 29.05.2023.
//

import SwiftUI

struct HistoryView: View {
    let sessionDataArray: [SessionDataModel]?
    
    var body: some View {
        VStack {
            if let sessionDataArray = sessionDataArray {
                ScrollView {
                    ForEach(sessionDataArray, id: \.self) { sessionData in
                        Text(sessionData.exercise)
                        Text("\(sessionData.count) reps")
                        Text("\(sessionData.seconds) sec")
                        Text(sessionData.date.formatted(
                            .dateTime
                                .day(.defaultDigits)
                                .month(.abbreviated)
                                .year(.defaultDigits)
                        ))
                        Divider()
                    }
                }
                .padding(10)
            } else {
                Text("No data to display.")
            }
        }
    }
}

//struct HistoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        HistoryView()
//    }
//}
