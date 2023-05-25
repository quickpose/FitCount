//
//  Text2Speech.swift
//  FitCount
//
//  Created by QuickPose.ai on 23.05.2023.
//

import Foundation
import AVFoundation


class Text2Speech {
    static let synthesizer = AVSpeechSynthesizer()
    
    var isSaid = false
    let text: String
    
    init(text: String) {
        self.text = text
    }
    
    func say() {
        if (isSaid) {
            return
        }
        
        let utterance = AVSpeechUtterance(string: self.text)
        Text2Speech.synthesizer.speak(utterance)
        
        self.isSaid = true
    }
}
