//
//  SplashModuleProtocols.swift
//  garageBand
//
//  Created  mark on 28/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

// MARK: - Presenter

protocol SplashModulePresenterProtocol: AnyObject {
    var view: SplashModuleViewProtocol? { get }
}

// MARK: - Interactor

protocol SplashModuleInteractorProtocol: AnyObject {
    var presenter: SplashModulePresenterProtocol? { get }
}

// MARK: - View

protocol SplashModuleViewProtocol: AnyObject {
    var interactor: SplashModuleInteractorProtocol? { get }
    var router: SplashModuleRouterProtocol? { get }
}

// MARK: - Router

protocol SplashModuleRouterProtocol: AnyObject {
    var viewController: UIViewController? { get }

    func openTutorial()
    func openMenuModule()
}
