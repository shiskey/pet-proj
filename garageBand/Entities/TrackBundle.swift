//
//  TrackBundle.swift
//  garageBand
//
//  Created by mark on 14/02/2022.
//  Copyright © 2022 mark All rights reserved.
//

import Foundation

struct TrackLoop: Decodable {
    
    var name: String { return self.audioName }
    let audioName: String
    let audioBell: String
    let iconNameDefault: String
    let iconNameActive: String
    let iconNameTimeline: String
    let iconColorDefault: String
    let iconColorActive: String
    
    let c1StrokeColor: String
    
    let c1ActiveStrokeColor: String
    let c2ActiveStrokeColor: String
    let c3ActiveStrokeColor: String
    
    // No static progress for c1
    let c2ActiveProgress: Float
    let c3ActiveProgress: Float
    
    let c1ActiveProgressColor: String
    let c2ActiveProgressColor: String
    let c3ActiveProgressColor: String
    
    let showOnBar: Int
    let hideOnBar: Int
}

struct TrackBundle: Decodable {

    let name: String
    let description: String
    let duration: String
    let bpm: Int
    let reverbPreset: Int
    let reverbDryWet: Double
    let mainPad: String
    let finalChord: String
    let tail: String
    let leadLoops: [TrackLoop]
    let bassLoops: [TrackLoop]
    let backgroungImage: String
    let leadProgressBarColor: String
    let bassProgressBarColor: String
    
}
