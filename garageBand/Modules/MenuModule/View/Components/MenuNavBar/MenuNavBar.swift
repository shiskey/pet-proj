//
//  MenuNavBar.swift
//  garageBand
//
//  Created by  mark on 19/10/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class MenuNavBar: UIView {

    var onMenuAction: (() -> ())?

    @IBAction func menuButtonTap() {
        self.onMenuAction?()
    }

}
