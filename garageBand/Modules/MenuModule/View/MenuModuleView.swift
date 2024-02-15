//
//  MenuModuleView.swift
//  garageBand
//
//  Created  mark on 29/07/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class MenuModuleView: UIViewController, MenuModuleViewProtocol {
	var interactor: MenuModuleInteractorProtocol?
    var router: MenuModuleRouterProtocol?
    var splashSnapshot: UIView?

    private var navBar: UIView!
    private var tableView: UITableView!

    private var items: [MenuModuleItem] = []
}

// MARK: - Lifecycle related

extension MenuModuleView {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
        self.loadItems()
    }

}

// MARK: - Setup

private extension MenuModuleView {

    func setup() {

        // setup navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navBar = {

            var hasTopNotch: Bool {
                return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
            }

            let b = UINib(
                nibName: "MenuNavBar",
                bundle: nil).instantiate(withOwner: self, options: nil).first as! MenuNavBar
            self.view.addSubview(b)
            b.translatesAutoresizingMaskIntoConstraints = false
            b.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            b.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            b.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            b.heightAnchor.constraint(equalToConstant: hasTopNotch ? 120 : 80).isActive = true

            b.onMenuAction = { [weak self] in
                self?.openSettings()
            }

            return b
        }()

        // setup tableView
        self.tableView = {
            let t = UITableView(frame: .zero, style: .plain)
            t.backgroundColor = .black
            t.showsVerticalScrollIndicator = false
            t.register(MenuModuleCell.xib, forCellReuseIdentifier: MenuModuleCell.reuseId)
            t.delegate = self
            t.dataSource = self
            t.separatorStyle = .none
            t.tableFooterView = UIView()
            self.view.addSubview(t)
            t.translatesAutoresizingMaskIntoConstraints = false
            t.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            t.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            t.topAnchor.constraint(equalTo: self.navBar.bottomAnchor).isActive = true
            t.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

            return t
        }()

        // set splash snapshot and remove after couple seconds
        if let splashSnapshot = self.splashSnapshot, let navView = self.navigationController?.view {
            navView.addSubview(splashSnapshot)
            splashSnapshot.translatesAutoresizingMaskIntoConstraints = false
            splashSnapshot.leadingAnchor.constraint(equalTo: navView.leadingAnchor).isActive = true
            splashSnapshot.trailingAnchor.constraint(equalTo: navView.trailingAnchor).isActive = true
            splashSnapshot.topAnchor.constraint(equalTo: navView.topAnchor).isActive = true
            splashSnapshot.bottomAnchor.constraint(equalTo: navView.bottomAnchor).isActive = true

            UIView.animate(withDuration: 1.0, delay: 3.0, options: [], animations: {
                splashSnapshot.alpha = 0.0
            }) { _ in
                splashSnapshot.removeFromSuperview()
            }
        }

    }

}

// MARK: - In/Out protocol

extension MenuModuleView {
    
}

// MARK: - Presenter -> Self

extension MenuModuleView {

    func displayItems(items: [MenuModuleItem]) {
        self.items = items
        self.tableView.reloadData()
    }

}

// MARK: - Actions

private extension MenuModuleView {

    func loadItems() {
        self.interactor?.loadItems()
    }

    @objc func openSettings() {
        self.router?.openSettings()
    }

}

// MARK: - TableViewDelegate

extension MenuModuleView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuModuleCell.reuseId, for: indexPath) as! MenuModuleCell
        let item = self.items[indexPath.row]
        cell.setup(model: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        self.router?.openTrackModule(for: item)
    }

}
