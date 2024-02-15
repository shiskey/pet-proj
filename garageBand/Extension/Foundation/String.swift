//
//  String.swift
//  garageBand
//
//  Created by mark on 16/02/2022.
//  Copyright © 2022 mark All rights reserved.
//

import SpriteKit

extension String {
    
    var colorFromHex: SKColor {
        return SKColor(hexString: self) ?? SKColor.red
    }
    
}
