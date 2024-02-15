//
//  SettingsModuleView.swift
//  garageBand
//
//  Created  mark on 08/09/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class SettingsModuleView: UIViewController, SettingsModuleViewProtocol {
	var interactor: SettingsModuleInteractorProtocol?
    var router: SettingsModuleRouterProtocol?

    private let tableView = UITableView()
    private let socialBar: SettingsModuleSocialBar = SettingsModuleSocialBar.loadFromXib()

    private let items = SettingsModuleItem.allCases
}

// MARK: - Lifecycle related

extension SettingsModuleView {
    /*
     Some code removed
     */
}

// MARK: - Setup

/*
 Some code removed
 */

// MARK: - In/Out protocol

extension SettingsModuleView {
    
}

// MARK: - Presenter -> Self

extension SettingsModuleView {
    
}

// MARK: - Actions

private extension SettingsModuleView {
    /*
     Some code removed
     */
}

// MARK: - TablerView delegate

extension SettingsModuleView: UITableViewDelegate, UITableViewDataSource {
    /*
     Some code removed
     */
}
