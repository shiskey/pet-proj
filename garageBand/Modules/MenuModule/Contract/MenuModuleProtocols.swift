//
//  MenuModuleProtocols.swift
//  garageBand
//
//  Created  mark on 29/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

// MARK: - Presenter

protocol MenuModulePresenterProtocol: AnyObject {
    var view: MenuModuleViewProtocol? { get }

    func presentItems(items: [MenuModuleItem])
}

// MARK: - Interactor

protocol MenuModuleInteractorProtocol: AnyObject {
    var presenter: MenuModulePresenterProtocol? { get }

    func loadItems()
}

// MARK: - View

protocol MenuModuleViewProtocol: AnyObject {
    var interactor: MenuModuleInteractorProtocol? { get }
    var router: MenuModuleRouterProtocol? { get }

    func displayItems(items: [MenuModuleItem])
}

// MARK: - Router

protocol MenuModuleRouterProtocol: AnyObject {
    var viewController: UIViewController? { get }

    func openTrackModule(for item: MenuModuleItem)
    func openSettings()
}
