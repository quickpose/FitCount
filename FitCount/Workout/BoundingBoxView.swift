//
//  BoundingBoxView.swift
//  FitCount
//
//  Created by QuickPose.ai on 25.05.2023.
//

import SwiftUI

struct BoundingBoxView: View {
    var isInBBox: Bool
    var indicatorWidth: Double
    
    init(isInBBox:Bool, indicatorWidth: Double) {
        self.isInBBox = isInBBox
        self.indicatorWidth = indicatorWidth
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isInBBox ? Color.green : Color.red, lineWidth: 5)
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
            }
        }.overlay(
            GeometryReader { geometry in
                VStack {
                    if (indicatorWidth > 0) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.green.opacity(0.5))
                            .frame(width: geometry.size.width * 0.6 * indicatorWidth, height: geometry.size.height * 0.8)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                }
            }
        )
        
    }
}
