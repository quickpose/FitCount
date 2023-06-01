//
//  AboutView.swift
//  FitCount
//
//  Created by QuickPose.ai on 01.06.2023.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 50) {
            Image("QuickPose-Logo")
                        .resizable()
                        .scaledToFit()
            
            
            VStack(spacing: 10) {
                Text("Our app is powered by QuickPose.AI iOS SDK.")
                Link(
                    "Learn more about QuickPose.AI",
                    destination: URL(string: "https://quickpose.ai")!
                ).font(.headline)
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Link("Give us feedback", destination: URL(string: "https://quickpose.ai")!)
                    .font(.headline)
            }
            .padding()
            .cornerRadius(8)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
