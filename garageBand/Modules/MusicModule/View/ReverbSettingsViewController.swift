//
//  ReverbSettingsViewController.swift
//  garageBand
//
//  Created by  mark on 23/12/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class ReverbSettingsViewController: UITableViewController {

    var items: [(Int, String)] = []
    var currentDryWet: Float = 0.0
    var onPresetSelected: ((Int) -> Void)?
    var onDryWetChanged: ((Double) -> Void)?

    private var dryWetLabel: UILabel!
    private var slider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.tableHeaderView = {

            let l = UILabel()
            l.text = "dry/wet \(self.currentDryWet)"
            self.dryWetLabel = l

            let s = UISlider()
            s.setValue(self.currentDryWet, animated: false)
            s.addTarget(self, action: #selector(changeDryWet(_:)), for: .valueChanged)
            self.slider = s

            let stack = UIStackView(arrangedSubviews: [l, s])
            stack.frame = CGRect(width: 320, height: 100)
            stack.axis = .vertical
            stack.spacing = 16
            return stack
        }()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(self.items[indexPath.row].0). \(self.items[indexPath.row].1)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.slider.setValue(0.0, animated: true)
        self.dryWetLabel.text = "dry/wet \(self.slider.value)"
        self.onDryWetChanged?(0.0)

        let selectedPreset = self.items[indexPath.row].0
        self.onPresetSelected?(selectedPreset)
    }

    @objc private func changeDryWet(_ slider: UISlider) {
        self.dryWetLabel.text = "dry/wet \(slider.value)"
        self.onDryWetChanged?(slider.value.double)
    }

}
