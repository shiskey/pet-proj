//
//  UIView.swift
//  garageBand
//
//  Created by  mark on 08/09/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

extension UIView {

    class func loadFromXib<T>(withOwner: Any? = nil, options: [UINib.OptionsKey: Any]? = nil) -> T where T: UIView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: String(describing: self), bundle: bundle)

        guard let view = nib.instantiate(withOwner: withOwner, options: options).first as? T else {
            fatalError("Could not load view from nib file.")
        }
        return view
    }

}
