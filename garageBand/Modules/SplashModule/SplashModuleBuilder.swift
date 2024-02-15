//
//  SplashModuleBuilder.swift
//  garageBand
//
//  Created  mark on 28/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class SplashModuleBuilder {
    
    func build() -> UIViewController {
        let view = SplashModuleView()
        let interactor = SplashModuleInteractor()
        let router = SplashModuleRouter()
        let presenter = SplashModulePresenter()
        
        view.interactor = interactor
        view.router = router
        interactor.presenter = presenter
        presenter.view = view
        router.viewController = view
        
        return view
    }
    
}
