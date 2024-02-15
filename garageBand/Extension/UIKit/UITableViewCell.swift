//
//  UITableViewCell.swift
//  garageBand
//
//  Created by  mark on 29/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

extension UITableViewCell {

    static var xib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    static var reuseId: String {
        return String(describing: self)
    }

}
