//
//  MenuModulePresenter.swift
//  garageBand
//
//  Created  mark on 29/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class MenuModulePresenter: MenuModulePresenterProtocol {
    weak var view: MenuModuleViewProtocol?
}

// MARK: - Interactor -> Self

extension MenuModulePresenter {

    func presentItems(items: [MenuModuleItem]) {
        self.view?.displayItems(items: items)
    }

}
