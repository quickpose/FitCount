//
//  VolumeChangeView.swift
//  FitCounter
//
//  Created by QuickPose.ai on 02.06.2023.
//

import SwiftUI
import MediaPlayer
import AVFoundation


func setSystemVolume(_ volume: Float) {
    let volumeView = MPVolumeView()
    let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
        slider?.setValue(volume, animated: false)
    }
}



func getCurrentVolume() -> Float {
    let audioSession = AVAudioSession.sharedInstance()
    
    do {
        try audioSession.setActive(true)
        
        let volume = audioSession.outputVolume
        return volume
    } catch {
        print("Failed to get current volume: \(error)")
        return 0.0
    }
}


struct VolumeChangeView: View {
    @State private var soundLevel: Float = getCurrentVolume()
    
    init() {
    }
    
    var body: some View {
        VStack {
            Color.white
                .ignoresSafeArea()
                .overlay(
                    VStack (spacing: 30){
                        Text("FitCounter provides real-time voice feedback")
                            .font(.title)
                            .multilineTextAlignment(.center)
                        Text("Please turn on the sound on your device")
                            .font(.body)
                            .multilineTextAlignment(.center)
                        
                        HStack {
                            Image(systemName: "speaker.wave.1")
                                .font(.system(size: 30))
                                .foregroundColor(.indigo)
                            
                            Slider(value: $soundLevel, in: 0...1, step: 0.01, onEditingChanged: { data in
                                setSystemVolume(self.soundLevel)
                            })
                            .tint(soundLevel < 0.5 ? .red : .green)
                            
                            Image(systemName: "speaker.wave.3")
                                .font(.system(size: 30))
                                .foregroundColor(.indigo)
                            
                        }
                    }.frame(width: 300)
                )
        }
    }
}

struct VolumeChangeView_Previews: PreviewProvider {
    static var previews: some View {
        VolumeChangeView()
    }
}
