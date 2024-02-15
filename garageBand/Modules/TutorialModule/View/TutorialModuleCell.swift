//
//  TutorialModuleCell.swift
//  garageBand
//
//  Created by  mark on 28/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class TutorialModuleCell: UICollectionViewCell {
    static let reuseId = "TutorialModuleCell"

    private var backgroundImage: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        fatalError("This method should be implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupCell()
    }

    private func setupCell() {

        self.backgroundImage = UIImageView()
        self.backgroundImage.layer.masksToBounds = true
        self.backgroundImage.contentMode = .scaleAspectFill
        self.addSubview(self.backgroundImage)
        self.backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImage.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.backgroundImage.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.backgroundImage.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.backgroundImage.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

}

// MARK: - Setup

extension TutorialModuleCell {

    func setup(with image: UIImage?) {
        self.backgroundImage.image = image
    }

}
