//
//  SettingsModuleRouter.swift
//  garageBand
//
//  Created  mark on 08/09/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class SettingsModuleRouter: SettingsModuleRouterProtocol {
	weak var viewController: UIViewController?
}

// MARK: - View -> Self

extension SettingsModuleRouter {

    func openTutorial() {
        if let window = UIApplication.shared.delegate?.window {
            window?.rootViewController = TutorialModuleBuilder().build()
        }
    }
}
