//
//  MenuModuleBuilder.swift
//  garageBand
//
//  Created  mark on 29/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class MenuModuleBuilder {
    
    func build(parentViewController: UIViewController? = nil, splashSnapshot: UIView? = nil) -> UINavigationController {
        let view = MenuModuleView()
        let interactor = MenuModuleInteractor()
        let router = MenuModuleRouter()
        let presenter = MenuModulePresenter()

        view.splashSnapshot = splashSnapshot
        view.interactor = interactor
        view.router = router
        interactor.presenter = presenter
        presenter.view = view
        router.viewController = view
        
        return UINavigationController(rootViewController: view)
    }
    
}
