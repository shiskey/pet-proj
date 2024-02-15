//
//  MusicWireframe.swift
//  garageBand
//
//  Created by mark on 13/02/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class MusicWireframe: MusicWireframeProtocol {
    
    private init() {  }
    
    static var mainStoryboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    static func createMusicModuleWith(trackBundle: TrackBundle) -> UIViewController {
        let viewController = mainStoryboard.instantiateInitialViewController()
        if let view = viewController as? MusicViewController {
            // let scene ...
            let wireFrame: MusicWireframeProtocol = MusicWireframe()
            let presenter: MusicPresenterProtocol = MusicPresenter()
            let mixer: MusicMixerProtocol = Mixer(trackBundle: trackBundle)
            
            mixer.presenter = presenter
            view.presenter = presenter
            view.trackBundle = trackBundle
            presenter.wireFrame = wireFrame
            presenter.view = view
            presenter.mixer = mixer
            
            return viewController!
        }
        return UIViewController()
    }
    
}
