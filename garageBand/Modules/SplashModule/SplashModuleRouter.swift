//
//  SplashModuleRouter.swift
//  garageBand
//
//  Created  mark on 28/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class SplashModuleRouter: SplashModuleRouterProtocol {
	weak var viewController: UIViewController?
}

// MARK: - View -> Self

extension SplashModuleRouter {

    func openTutorial() {
        if let window = UIApplication.shared.delegate?.window {
            window?.rootViewController = TutorialModuleBuilder().build()
        }
    }

    func openMenuModule() {
        if let window = UIApplication.shared.delegate?.window {
            let splashSnapshot = self.viewController?.view.snapshotView(afterScreenUpdates: true)
            window?.rootViewController = MenuModuleBuilder().build(parentViewController: nil, splashSnapshot: splashSnapshot)
        }
    }

}
