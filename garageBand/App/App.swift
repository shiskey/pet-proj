//
//  App.swift
//  garageBand
//
//  Created by mark on 18/02/2022.
//  Copyright © 2022 mark All rights reserved.
//

import Foundation

struct App {

    private init() {  }

    static var isTutorialPassed: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "tutorial")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "tutorial")
            UserDefaults.standard.synchronize()
        }
    }

    struct Settings {
        static var isDebug: Bool {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }
    }
    
}
