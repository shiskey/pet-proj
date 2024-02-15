//
//  SettingsModuleProtocols.swift
//  garageBand
//
//  Created  mark on 08/09/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

// MARK: - Presenter

protocol SettingsModulePresenterProtocol: AnyObject {
    var view: SettingsModuleViewProtocol? { get }
}

// MARK: - Interactor

protocol SettingsModuleInteractorProtocol: AnyObject {
    var presenter: SettingsModulePresenterProtocol? { get }    
}

// MARK: - View

protocol SettingsModuleViewProtocol: AnyObject {
    var interactor: SettingsModuleInteractorProtocol? { get }
    var router: SettingsModuleRouterProtocol? { get }
}

// MARK: - Router

protocol SettingsModuleRouterProtocol: AnyObject {
    var viewController: UIViewController? { get }

    func openTutorial()
}
