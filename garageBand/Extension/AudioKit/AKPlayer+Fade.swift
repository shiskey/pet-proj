//
//  AKPlayer+Fade.swift
//  garageBand
//
//  Created by  mark on 20/10/2022.
//  Copyright © 2022 mark All rights reserved.
//

import AudioKit

extension AKPlayer {

    @objc func fadeOutFor1Second() {
        if volume > 0.1 {
            // Fade
            volume -= 0.1
            perform(#selector(fadeOutFor1Second), with: nil, afterDelay: 0.1)
        } else {
            // Stop and get the sound ready for playing again
            stop()
            volume = 1.0
        }
    }

    @objc func fadeOutAndPause() {
        if volume > 0.1 {
            // Fade
            volume -= 0.1
            perform(#selector(fadeOutAndPause), with: nil, afterDelay: 0.1)
        } else {
            // Stop and get the sound ready for playing again
            self.pause()
            volume = 1.0
        }
    }

}
