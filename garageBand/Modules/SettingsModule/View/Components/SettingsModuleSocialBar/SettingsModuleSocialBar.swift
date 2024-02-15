//
//  SettingsModuleSocialBar.swift
//  garageBand
//
//  Created by  mark on 08/09/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class SettingsModuleSocialBar: UIView {

    var onFacebookClick: (() -> Void)?
    var onTwitterClick: (() -> Void)?

    
    @IBAction
    func onFacebookAction() {
        self.onFacebookClick?()
    }

    @IBAction
    func onTwitterAction() {
        self.onTwitterClick?()
    }

}
