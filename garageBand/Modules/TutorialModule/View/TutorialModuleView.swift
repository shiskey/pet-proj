//
//  TutorialModuleView.swift
//  garageBand
//
//  Created  mark on 28/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class TutorialModuleView: UIViewController, TutorialModuleViewProtocol {
	var interactor: TutorialModuleInteractorProtocol?
    var router: TutorialModuleRouterProtocol?

    enum State {
        case `default`, isLastPage
    }

    private var collectionView: UICollectionView!
    private var pageControl: UIPageControl!
    private var closeButton: UIButton!
    private var okButton: UIButton!

    private var state: State = .default {
        didSet {
            switch state {
            case .isLastPage:
                self.okButton.isHidden = false
                self.closeButton.isHidden = true
            default:
                self.okButton.isHidden = true
                self.closeButton.isHidden = false
            }
        }
    }

    private var items: [UIImage] = TutorialModuleItem.items.compactMap({ UIImage(named: $0) })
}

// MARK: - Lifecycle related

extension TutorialModuleView {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }

}

// MARK: - Setup

private extension TutorialModuleView {

    func setup() {

        // setup background image view (for iphone X)
        let backgroundImageView = UIImageView(image: UIImage(named: "tutorial-1")!)
        self.view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // setup collectionView
        self.collectionView = {
            let l = UICollectionViewFlowLayout()
            l.scrollDirection = .horizontal
            l.minimumInteritemSpacing = 0
            l.minimumLineSpacing = 0

            let c = UICollectionView(frame: .zero, collectionViewLayout: l)
            c.dataSource = self
            c.delegate = self
            c.bounces = false
            c.showsHorizontalScrollIndicator = false
            c.isPagingEnabled = true
            c.register(TutorialModuleCell.self, forCellWithReuseIdentifier: TutorialModuleCell.reuseId)
            self.view.addSubview(c)
            c.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                c.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                c.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                c.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                c.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
            ])
            return c
        }()

        // setup pageControl
        self.pageControl = {
            let p = UIPageControl()
            p.isUserInteractionEnabled = false
            p.numberOfPages = self.items.count
            p.currentPage = 0
            p.currentPageIndicatorTintColor = UIColor(hexString: "ff9900")
            p.pageIndicatorTintColor = UIColor(hexString: "d0d2d4")
            self.view.addSubview(p)
            p.translatesAutoresizingMaskIntoConstraints = false
            p.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
            p.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

            return p
        }()

        // setup right button
        self.closeButton = {
            let b = UIButton(type: .system)
            b.tintColor = .white
            b.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            b.setTitle("╳", for: .normal)
            b.addTarget(self, action: #selector(closeTutorial), for: .touchUpInside)
            self.view.addSubview(b)
            b.translatesAutoresizingMaskIntoConstraints = false
            b.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
            b.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true

            return b
        }()

        // setup ok button
        self.okButton = {
            let b = UIButton(type: .system)
            b.setBackgroundImage(UIImage(named: "tutorial-ok-button")!, for: .normal)
            b.addTarget(self, action: #selector(closeTutorial), for: .touchUpInside)
            self.view.addSubview(b)
            b.translatesAutoresizingMaskIntoConstraints = false
            b.widthAnchor.constraint(equalToConstant: 48).isActive = true
            b.heightAnchor.constraint(equalToConstant: 48).isActive = true
            b.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -96).isActive = true
            b.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

            return b
        }()

        // set initial state
        self.state = .default

    }

}

// MARK: - In/Out protocol

extension TutorialModuleView {

}

// MARK: - Presenter -> Self

extension TutorialModuleView {

}

// MARK: - Actions

private extension TutorialModuleView {

    func updatePageControl(with index: Int) {
        self.pageControl.currentPage = index
        self.state = (self.pageControl.currentPage == self.items.count-1) ? State.isLastPage : State.default
    }

    @objc func closeTutorial() {
        self.router?.openMenuModule()
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension TutorialModuleView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x / self.view.frame.width)
        self.updatePageControl(with: pageNumber)
    }

}

// MARK: - UICollectionView delegate

extension TutorialModuleView: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorialModuleCell.reuseId,
                                                      for: indexPath) as! TutorialModuleCell

        let image = self.items[indexPath.row]
        cell.setup(with: image)

        return cell
    }

}
