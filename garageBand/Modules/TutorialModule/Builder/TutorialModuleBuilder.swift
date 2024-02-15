//
//  TutorialModuleBuilder.swift
//  garageBand
//
//  Created  mark on 28/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class TutorialModuleBuilder {
    
    func build() -> UIViewController {
        let view = TutorialModuleView()
        let interactor = TutorialModuleInteractor()
        let router = TutorialModuleRouter()
        let presenter = TutorialModulePresenter()
        
        view.interactor = interactor
        view.router = router
        interactor.presenter = presenter
        presenter.view = view
        router.viewController = view
        
        return view
    }
    
}
