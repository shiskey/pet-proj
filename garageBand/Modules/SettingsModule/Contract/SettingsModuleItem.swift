//
//  SettingsModuleItem.swift
//  garageBand
//
//  Created by  mark on 08/09/2022.
//  Copyright © 2022 mark All rights reserved.
//

import Foundation

enum SettingsModuleItem: String, CaseIterable {
    case tutorial, about, contact

    var name: String {
        return self.rawValue.capitalized
//        switch self {
//        case .about:
//            return "About"
//        case .tutorial:
//            return "Tutorial"
//        case .contact:
//            return "Contact"
//        }
    }
}
