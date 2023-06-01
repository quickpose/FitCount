//
//  AboutView.swift
//  FitCount
//
//  Created by QuickPose.ai on 01.06.2023.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 50) {
                VStack(spacing: 10) {
                    Text("Our app is powered by QuickPose.ai iOS SDK.")
                        .padding(.top, 50)
                    Link(
                        "Learn more about QuickPose.ai",
                        destination: URL(string: "http://linktr.ee/quickpose?utm_source=fitcounter")!
                    ).font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Link("Help us improve", destination: URL(string: "https://forms.gle/ebHP58NeeYGEoBcb8")!)
                        .font(.headline)
                }
                .padding()
                .cornerRadius(8)
            }.navigationBarTitle("About")
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
