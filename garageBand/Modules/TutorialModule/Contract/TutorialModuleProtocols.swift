//
//  TutorialModuleProtocols.swift
//  garageBand
//
//  Created  mark on 28/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

// MARK: - Presenter

protocol TutorialModulePresenterProtocol: AnyObject {
    var view: TutorialModuleViewProtocol? { get }
}

// MARK: - Interactor

protocol TutorialModuleInteractorProtocol: AnyObject {
    var presenter: TutorialModulePresenterProtocol? { get }
}

// MARK: - View

protocol TutorialModuleViewProtocol: AnyObject {
    var interactor: TutorialModuleInteractorProtocol? { get }
    var router: TutorialModuleRouterProtocol? { get }
}

// MARK: - Router

protocol TutorialModuleRouterProtocol: AnyObject {
    var viewController: UIViewController? { get }

    func openMenuModule()
}
