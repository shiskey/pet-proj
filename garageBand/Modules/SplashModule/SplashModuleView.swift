//
//  SplashModuleView.swift
//  garageBand
//
//  Created  mark on 28/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class SplashModuleView: UIViewController, SplashModuleViewProtocol {
	var interactor: SplashModuleInteractorProtocol?
    var router: SplashModuleRouterProtocol?

    private var backgroundImageView: UIImageView!
}

// MARK: - Lifecycle related

extension SplashModuleView {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if App.isTutorialPassed {
                self.router?.openMenuModule()
            } else {
                self.router?.openTutorial()
            }
        }
    }

}

// MARK: - Setup

private extension SplashModuleView {

    func setup() {

        self.backgroundImageView = {
            let v = UIImageView(frame: .zero)
            v.image = UIImage(named: "splash-screen")
            v.contentMode = .scaleAspectFill
            self.view.addSubview(v)
            v.translatesAutoresizingMaskIntoConstraints = false
            v.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            v.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            v.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            v.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

            return v
        }()

    }

}

// MARK: - In/Out protocol

extension SplashModuleView {
    
}

// MARK: - Presenter -> Self

extension SplashModuleView {
    
}

// MARK: - Actions

private extension SplashModuleView {

}
