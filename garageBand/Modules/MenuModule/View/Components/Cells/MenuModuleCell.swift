//
//  MenuModuleCell.swift
//  garageBand
//
//  Created by  mark on 29/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class MenuModuleCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var highlightView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

// MARK: - Setup

extension MenuModuleCell {

    func setup(model: MenuModuleItem) {
        self.nameLabel.text = model.name
        self.descriptionLabel.text = model.description
        self.durationLabel.text = model.duration
        self.backgroundImageView.image = UIImage(named: model.image)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        self.highlightView.alpha = highlighted ? 0.5 : 0.0
    }

}
