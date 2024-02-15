//
//  SettingsModuleBuilder.swift
//  garageBand
//
//  Created  mark on 08/09/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class SettingsModuleBuilder {
    
    func build(parentViewController: UIViewController? = nil) -> UIViewController {
        let view = SettingsModuleView()
        let interactor = SettingsModuleInteractor()
        let router = SettingsModuleRouter()
        let presenter = SettingsModulePresenter()
        
        view.interactor = interactor
        view.router = router
        interactor.presenter = presenter
        presenter.view = view
        router.viewController = parentViewController
        
        return view
    }
    
}
