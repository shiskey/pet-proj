//
//  MainScene.swift
//  garageBand
//
//  Created by mark on 31/01/2022.
//  Copyright © 2022 mark All rights reserved.
//

import SpriteKit
import AudioKit

class MainScene: SKScene {
    
    var onTapButton: ((String, String) -> ())?
    var onUpdateFrame: (() -> ())?
    
    private var trackBundle: TrackBundle!
    private var gravityTimer: Timer?
    
    private var progressBar: ProgressBar!
    private var topArea: LoopArea!
    private var bottomArea: LoopArea!
    private var topButtons: [LoopButton] = [LoopButton]()
    private var bottomButtons: [LoopButton] = [LoopButton]()
    private var allButtons: [LoopButton] {
        return self.topButtons + self.bottomButtons
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(size: CGSize, trackBundle: TrackBundle) {
        super.init(size: size)
        
        // setup self
        self.trackBundle = trackBundle
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.gravityTimer = Timer.scheduledTimer(
            timeInterval: 10.0,
            target: self,
            selector: #selector(sceneActions),
            userInfo: nil,
            repeats: true
        )
        
        // setup progress bar
        let f = try! AKAudioFile(readFileName: trackBundle.mainPad)
        let p = AKPlayer(audioFile: f)
        let barTime = trackBundle.bpm / 60
        let barsCount = Int(p.duration / barTime)
        self.progressBar = ProgressBar(
            size: self.progressBarFrame.size, 
            barsCount: barsCount,
            leadProgressBarColor: trackBundle.leadProgressBarColor.colorFromHex, 
            bassProgressBarColor: trackBundle.bassProgressBarColor.colorFromHex
        )
        self.progressBar.position = self.progressBarFrame.origin
        self.addChild(self.progressBar)
        
        // setup top area
        self.topArea = LoopArea(size: self.topAreaFrame.size)
        self.topArea.position = self.topAreaFrame.origin
        self.addChild(self.topArea)
        
        // setup bottom area
        self.bottomArea = LoopArea(size: self.bottomAreaFrame.size)
        self.bottomArea.position = self.bottomAreaFrame.origin
        self.addChild(self.bottomArea)
        
        // setup top loop buttons
        for l in self.trackBundle.leadLoops {
            let button = LoopButton(
                name: l.name,
                radius: size.width/10.0,
                iconNameDefault: l.iconNameDefault,
                iconNameActive: l.iconNameActive,
                iconColorDefault: l.iconColorDefault.colorFromHex,
                iconColorActive: l.iconColorActive.colorFromHex,
                c1StrokeColor: l.c1StrokeColor.colorFromHex,
                c1ActiveStrokeColor: l.c1ActiveStrokeColor.colorFromHex,
                c2ActiveStrokeColor: l.c2ActiveStrokeColor.colorFromHex,
                c3ActiveStrokeColor: l.c3ActiveStrokeColor.colorFromHex,
                c2ActiveProgress: l.c2ActiveProgress.cgFloat,
                c3ActiveProgress: l.c3ActiveProgress.cgFloat,
                c1ActiveProgressColor: l.c1ActiveProgressColor.colorFromHex,
                c2ActiveProgressColor: l.c2ActiveProgressColor.colorFromHex,
                c3ActiveProgressColor: l.c3ActiveProgressColor.colorFromHex,
                tapAction: { [weak self] name in
                    self?.onTapButton?(name, l.audioBell)
                }
            )
            self.topButtons.append(button)
        }

        // setup bottom loop buttons
        for l in self.trackBundle.bassLoops {
            let button = LoopButton(
                name: l.name,
                radius: size.width/10.0,
                iconNameDefault: l.iconNameDefault,
                iconNameActive: l.iconNameActive,
                iconColorDefault: l.iconColorDefault.colorFromHex,
                iconColorActive: l.iconColorActive.colorFromHex,
                c1StrokeColor: l.c1StrokeColor.colorFromHex,
                c1ActiveStrokeColor: l.c1ActiveStrokeColor.colorFromHex,
                c2ActiveStrokeColor: l.c2ActiveStrokeColor.colorFromHex,
                c3ActiveStrokeColor: l.c3ActiveStrokeColor.colorFromHex,
                c2ActiveProgress: l.c2ActiveProgress.cgFloat,
                c3ActiveProgress: l.c3ActiveProgress.cgFloat,
                c1ActiveProgressColor: l.c1ActiveProgressColor.colorFromHex,
                c2ActiveProgressColor: l.c2ActiveProgressColor.colorFromHex,
                c3ActiveProgressColor: l.c3ActiveProgressColor.colorFromHex,
                tapAction: { [weak self] name in
                    self?.onTapButton?(name, l.audioBell)
                }
            )
            self.bottomButtons.append(button)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.onUpdateFrame?()
    }
}

// MARK: ViewController -> Scene

extension MainScene {
    
    func showButtonFor(bar number: Int) {
        let buttons = self.buttonsToShowFor(bar: number)
        buttons.forEach { b in
            switch b.position {
            case .top:
                self.topArea.add(button: b.button)
            case .bottom:
                self.bottomArea.add(button: b.button)
            }
        }
    }
    
    func hideButtonFor(bar number: Int) {
        let buttons = self.buttonsToHideFor(bar: number)
        buttons.forEach { b in
            switch b.position {
            case .top:
                self.topArea.remove(button: b.button)
            case .bottom:
                self.bottomArea.remove(button: b.button)
            }
        }
    }
    
    func startButtonPending(with name: String, duration: Double) {
        self.button(for: name).pendingStart(with: duration)
    }
    
    func cancelButtonPending(with name: String) {
        self.button(for: name).pendingCancel()
    }
    
    func activateButton(with name: String, progressDuration: Double) {
        self.button(for: name).activate(with: progressDuration)
    }
    
    func deactivateButton(with name: String) {
        self.button(for: name).deactivate()
    }
    
    func addToTimelineButton(with name: String) {
        if let iconAndPos = self.timeLineIcon(for: name) {
            self.progressBar.addMarker(with: iconAndPos.icon, with: iconAndPos.position)
        }
    }
    
    func showWave(for leadInstruments: Double, for bassInstruments: Double) {
        self.progressBar.showWaveWithAmplitude(for: leadInstruments, for: bassInstruments)
    }
    
    func showProgress(for progress: CGFloat, animation durations: Double) {
        // ignore mixer's timer ticks while paused
        if self.isPaused { return }
        self.progressBar.showProgress(with: progress, animation: durations)
    }
    
    func throwawayButtons() {
        self.topArea.throwawayButtons()
        self.bottomArea.throwawayButtons()
    }

    func hideTimeline() {
        let fadeOutAction = SKAction.fadeOut(withDuration: 4.0)
        self.progressBar.run(fadeOutAction)
    }
    
}

// MARK: Scene actions

extension MainScene {
    
    @objc private func sceneActions() {
        // ignore timer ticks while paused
        if self.isPaused { return }

        self.calculateGravity()
        self.makeRipple()
    }
    
    private func calculateGravity() {
        self.topArea.calculateGravity()
        self.bottomArea.calculateGravity()
    }
    
    private func makeRipple() {
        
        if let randomButton = (self.topArea.children + self.bottomArea.children)
            .compactMap({ $0 as? LoopButton })
            .randomElement() {
            if let position = randomButton.positionInScene {
                let c = Circle(radius: randomButton.radius, strokeWidth: 2.0, strokeColor: randomButton.iconColorCurrent)
                c.position = position
                self.insertChild(c, at: 0)
                let raduisAction = c.radiusAnimation(radius: 500.0, duration: 3.0)
                let strokeAction = c.strokeWidthAnimation(width: 0.5, duration: 3.0)
                let fadeAction = SKAction.fadeOut(withDuration: 1.5)
                c.run(
                    SKAction.group([raduisAction, strokeAction, fadeAction]),
                    completion: {
                        c.removeFromParent()
                })
            }
        }
        
    }

}

// MARK: Utils

extension MainScene {
    
    private func button(for name: String) -> LoopButton {
        guard let button = self.allButtons.first(where: { $0.name == name }) else {
            fatalError(">>> \(#file) - \(#function): There is no button with name \(name)")
        }
        return button
    }
    
    private func buttonsToShowFor(bar number: Int) -> [(button: LoopButton, position: LoopButtonPosition)] {
        var buttons = [(LoopButton, LoopButtonPosition)]()
        
        if let topLoops = self.trackBundle?.leadLoops {
            let loopsForBar = topLoops.filter { $0.showOnBar == number }
            loopsForBar.forEach { loop in
                let button = self.button(for: loop.name)
                buttons.append((button, .top))
            }
        }
        
        if let bottomLoops = self.trackBundle?.bassLoops {
            let loopsForBar = bottomLoops.filter { $0.showOnBar == number }
            loopsForBar.forEach { loop in
                let button = self.button(for: loop.name)
                buttons.append((button, .bottom))
            }
        }
        
        return buttons
    }
    
    private func buttonsToHideFor(bar number: Int) -> [(button: LoopButton, position: LoopButtonPosition)] {
        var buttons = [(LoopButton, LoopButtonPosition)]()
        
        if let topLoops = self.trackBundle?.leadLoops {
            let loopsForBar = topLoops.filter { $0.hideOnBar == number }
            loopsForBar.forEach { loop in
                let button = self.button(for: loop.name)
                buttons.append((button, .top))
            }
        }
        
        if let bottomLoops = self.trackBundle?.bassLoops {
            let loopsForBar = bottomLoops.filter { $0.hideOnBar == number }
            loopsForBar.forEach { loop in
                let button = self.button(for: loop.name)
                buttons.append((button, .bottom))
            }
        }
        
        return buttons
    }
    
    private func timeLineIcon(for name: String) -> (icon: String, position: LoopButtonPosition)? {
        if let topLoops = self.trackBundle?.leadLoops {
            if let loop = topLoops.first(where: { $0.name == name }) {
                return (icon: loop.iconNameTimeline, position: .top)
            }
        }
        if let bottomLoops = self.trackBundle?.bassLoops {
            if let loop = bottomLoops.first(where: { $0.name == name }) {
                return (icon: loop.iconNameTimeline, position: .bottom)
            }
        }
        return nil
    }
    
}

// MARK: Scene's computed properties

extension MainScene {
    
    private var margin64: CGFloat {
        return self.size.width / 9.0
    }
    private var radius: CGFloat {
        return self.size.height / 12.0
    }
    private var topAreaFrame: CGRect {
        return CGRect(
            x: 0,
            y: self.size.height/2 + margin64,
            width: self.size.width,
            height: self.size.height/2 - margin64
        )
    }
    private var bottomAreaFrame: CGRect {
        return CGRect(
            x: 0,
            y: 0,
            width: self.size.width,
            height: self.size.height/2 - margin64
        )
    }
    private var progressBarFrame: CGRect {
        return CGRect(
            x: 0,
            y: self.size.height/2-margin64,
            width: self.size.width,
            height: margin64*2
        )
    }
    
}
