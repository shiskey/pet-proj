//
//  ControlButtons.swift
//  garageBand
//
//  Created by  mark on 28/10/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

protocol ControlButtonsDelegate: AnyObject {
    func controlButtonsTap(button: ControlButtons.Button, at state: ControlButtons.State)
}

class ControlButtons: UIView {

    enum State {
        // state map
        // play: PAUSE STOP
        // pause: PLAY STOP
        // tailPlay: PAUSE MENU
        // tailPause: PLAY MENU
        case play, pause, tailPlay, tailPause
    }

    enum Button {
        case play, pause, stop, menu
    }

    weak var delegate: ControlButtonsDelegate?
    var state: State = .play {
        didSet {
            switch self.state {
            case .play:
                self.playButton.isHidden = true
                self.pauseButton.isHidden = false
                self.stopButton.isHidden = false
                self.menuButton.isHidden = true
            case .pause:
                self.playButton.isHidden = false
                self.pauseButton.isHidden = true
                self.stopButton.isHidden = false
                self.menuButton.isHidden = true
            case .tailPlay:
                self.playButton.isHidden = true
                self.pauseButton.isHidden = false
                self.stopButton.isHidden = true
                self.menuButton.isHidden = false
            case .tailPause:
                self.playButton.isHidden = false
                self.pauseButton.isHidden = true
                self.stopButton.isHidden = true
                self.menuButton.isHidden = false
            }
        }
    }

    private let stack = UIStackView()
    private let playButton = UIButton(type: .system)
    private let pauseButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)
    private let menuButton = UIButton(type: .system)

    private var allButtons: [UIButton] {
        return [self.playButton, self.pauseButton, self.stopButton, self.menuButton]
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    private func setup() {

        // setup stackView
        self.stack.spacing = 32
        self.stack.axis = .horizontal
        self.stack.alignment = .center
        self.addSubview(self.stack)
        self.stack.translatesAutoresizingMaskIntoConstraints = false
        self.stack.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        // setup playButton
        self.playButton.setImage(UIImage(named: "play")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.playButton.tintColor = .white
        self.stack.addArrangedSubview(self.playButton)
        self.playButton.translatesAutoresizingMaskIntoConstraints = false
        self.playButton.widthAnchor.constraint(equalTo: self.playButton.heightAnchor, multiplier: 1.0/1.0).isActive = true

        // setup pauseButton
        self.pauseButton.setImage(UIImage(named: "pause")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.pauseButton.tintColor = .white
        self.stack.addArrangedSubview(self.pauseButton)
        self.pauseButton.translatesAutoresizingMaskIntoConstraints = false
        self.pauseButton.widthAnchor.constraint(equalTo: self.pauseButton.heightAnchor, multiplier: 1.0/1.0).isActive = true

        // setup stopButton
        self.stopButton.setImage(UIImage(named: "stop")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.stopButton.tintColor = .white
        self.stack.addArrangedSubview(self.stopButton)
        self.stopButton.translatesAutoresizingMaskIntoConstraints = false
        self.stopButton.widthAnchor.constraint(equalTo: self.stopButton.heightAnchor, multiplier: 1.0/1.0).isActive = true

        // setup menuButton
        self.menuButton.setImage(UIImage(named: "exit")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.menuButton.tintColor = .white
        self.stack.addArrangedSubview(self.menuButton)
        self.menuButton.translatesAutoresizingMaskIntoConstraints = false
        self.menuButton.widthAnchor.constraint(equalTo: self.menuButton.heightAnchor, multiplier: 1.0/1.0).isActive = true

        // setup allButtons
        self.allButtons.forEach({
            $0.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        })

    }

    @objc private func buttonAction(sender: UIButton) {
        if sender == self.playButton {
            self.delegate?.controlButtonsTap(button: .play, at: self.state)
        }
        if sender == self.pauseButton {
            self.delegate?.controlButtonsTap(button: .pause, at: self.state)
        }
        if sender == self.stopButton {
            self.delegate?.controlButtonsTap(button: .stop, at: self.state)
        }
        if sender == self.menuButton {
            self.delegate?.controlButtonsTap(button: .menu, at: self.state)
        }
    }

}

extension ControlButtons {

    func enableButtons() {
        self.allButtons.forEach({ $0.isEnabled = true })
    }

    func disableButtons() {
        self.allButtons.forEach({ $0.isEnabled = false })
    }

}
