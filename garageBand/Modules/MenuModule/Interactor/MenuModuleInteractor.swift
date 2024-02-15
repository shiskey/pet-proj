//
//  MenuModuleInteractor.swift
//  garageBand
//
//  Created  mark on 29/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import Foundation

class MenuModuleInteractor: MenuModuleInteractorProtocol {
    var presenter: MenuModulePresenterProtocol?
}

// MARK: - View -> Self

extension MenuModuleInteractor {

    func loadItems() {
        var items = [MenuModuleItem]()

        let jsonFilesUrls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil)!
        for jsonFileUrl in jsonFilesUrls {
            if let jsonString = try? String(contentsOf: jsonFileUrl) {
                let jsonData = jsonString.data(using: .utf8)!
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let trackBundle = try! jsonDecoder.decode(TrackBundle.self, from: jsonData)

                let item = MenuModuleItem(
                    name: trackBundle.name,
                    description: trackBundle.description,
                    duration: trackBundle.duration,
                    image: trackBundle.backgroungImage,
                    trackBundle: trackBundle
                )

                items.append(item)
            }
        }

        self.presenter?.presentItems(items: items)
    }

}
