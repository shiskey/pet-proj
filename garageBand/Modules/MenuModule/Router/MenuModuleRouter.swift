//
//  MenuModuleRouter.swift
//  garageBand
//
//  Created  mark on 29/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class MenuModuleRouter: NSObject, MenuModuleRouterProtocol {
	weak var viewController: UIViewController?
}

// MARK: - View -> Self

extension MenuModuleRouter {

    func openTrackModule(for item: MenuModuleItem) {
        let trackBundle = item.trackBundle
        let trackModule = MusicWireframe.createMusicModuleWith(trackBundle: trackBundle)
        trackModule.modalPresentationStyle = .custom
        trackModule.transitioningDelegate = self

        self.viewController?.present(trackModule, animated: true, completion: nil)
    }

    func openSettings() {
        let settingsModule = SettingsModuleBuilder().build()
        self.viewController?.show(settingsModule, sender: nil)
    }

}

// MARK: - Transition delegate

extension MenuModuleRouter:  UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension MenuModuleRouter: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animationDuration = transitionDuration(using: transitionContext)
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        let containerView = transitionContext.containerView

        let isPresenting = toVC != self.viewController?.navigationController

        if isPresenting {
            toVC.view.alpha = 0.0
            containerView.addSubview(toVC.view)
            UIView.animate(withDuration: animationDuration, animations: {
                toVC.view.alpha = 1.0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        } else {
            UIView.animate(withDuration: animationDuration, animations: {
                fromVC.view.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }

    }

}
