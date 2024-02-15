//
//  AudioFabric.swift
//  garageBand
//
//  Created by mark on 14/02/2022.
//  Copyright © 2022 mark All rights reserved.
//

import AudioKit

struct AudioFabric {
    
    private init() {  }
    
    static func loop(fileName: String, shouldLooping: Bool = false, shouldBuffer: Bool = true) -> AKPlayer {
        let f = try! AKAudioFile(readFileName: fileName)
        let p = AKPlayer(audioFile: f)

        if shouldBuffer {
            // This line cause crashes sometime and freezes on long "tail" audiofiles
            p.buffering = .always
        }
        
        if shouldLooping {
            p.isLooping = true
            p.preroll()
        }

        p.prepare()

        // preheat fader
        p.fadeOutAndStop(time: 0.1)
        p.startFader()

        return p
    }
}
