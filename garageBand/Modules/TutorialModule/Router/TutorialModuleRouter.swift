//
//  TutorialModuleRouter.swift
//  garageBand
//
//  Created  mark on 28/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class TutorialModuleRouter: TutorialModuleRouterProtocol {
	weak var viewController: UIViewController?
}

// MARK: - View -> Self

extension TutorialModuleRouter {

    func openMenuModule() {

        App.isTutorialPassed = true

        if let window = UIApplication.shared.delegate?.window {
            window?.rootViewController = MenuModuleBuilder().build()
        }
    }

}
