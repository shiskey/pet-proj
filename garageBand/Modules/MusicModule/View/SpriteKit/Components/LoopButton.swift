//
//  LoopButton.swift
//  garageBand
//
//  Created by mark on 02/02/2022.
//  Copyright © 2022 mark All rights reserved.
//

import SpriteKit

private let ANIMATION_TIME = 0.3
private let RADIUS_INCREASE: CGFloat = 2.0

class LoopButton: SKNode {

    var radius: CGFloat = 0.0
    var iconColorCurrent: SKColor { self.icon.color }
    private var loopName: String!

    private var iconNameDefault: String!
    private var iconNameActive: String!
    private var iconColorDefault: SKColor!
    private var iconColorActive: SKColor!

    private var c1StrokeColor: SKColor!

    private var c1ActiveStrokeColor: SKColor!
    private var c2ActiveStrokeColor: SKColor!
    private var c3ActiveStrokeColor: SKColor!

    // No static progress for c1
    private var c2ActiveProgress: CGFloat!
    private var c3ActiveProgress: CGFloat!

    private var c1ActiveProgressColor: SKColor!
    private var c2ActiveProgressColor: SKColor!
    private var c3ActiveProgressColor: SKColor!

    private var onTapAction: ((String) -> ())!
    private var c1: Circle!
    private var c2: Circle!
    private var c3: Circle!
    private var pendingCircle: Circle?
    private var icon: SKSpriteNode!
    private var physicRadius: CGFloat = 0.0 {
        didSet {
            self.physicsBody = LoopButton.generatePhysicBody(for: physicRadius)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        name: String,
        radius: CGFloat,
        iconNameDefault: String,
        iconNameActive: String,
        iconColorDefault: SKColor,
        iconColorActive: SKColor,
        c1StrokeColor: SKColor,
        c1ActiveStrokeColor: SKColor,
        c2ActiveStrokeColor: SKColor,
        c3ActiveStrokeColor: SKColor,
        c2ActiveProgress: CGFloat,
        c3ActiveProgress: CGFloat,
        c1ActiveProgressColor: SKColor,
        c2ActiveProgressColor: SKColor,
        c3ActiveProgressColor: SKColor,
        tapAction: @escaping ((String) -> ())
        ) {
        super.init()

        // setup self
        self.name = name
        self.loopName = name
        self.radius = radius
        self.iconNameDefault = iconNameDefault
        self.iconNameActive = iconNameActive
        self.iconColorDefault = iconColorDefault
        self.iconColorActive = iconColorActive
        self.c1StrokeColor = c1StrokeColor
        self.c1ActiveStrokeColor = c1ActiveStrokeColor
        self.c2ActiveStrokeColor = c2ActiveStrokeColor
        self.c3ActiveStrokeColor = c3ActiveStrokeColor
        self.c2ActiveProgress = c2ActiveProgress
        self.c3ActiveProgress = c3ActiveProgress
        self.c1ActiveProgressColor = c1ActiveProgressColor
        self.c2ActiveProgressColor = c2ActiveProgressColor
        self.c3ActiveProgressColor = c3ActiveProgressColor
        self.onTapAction = tapAction

        // setup icon
        let image = UIImage(named: iconNameDefault)!
        let texture = SKTexture(image: image)
        self.icon = SKSpriteNode(texture: texture)
        self.icon.colorBlendFactor = 1.0
        self.icon.color = self.iconColorDefault
        self.icon.size = CGSize(width: self.radius, height: self.radius)
        self.addChild(self.icon)

        // setup idle state
        self.c1 = Circle(
            radius: self.radius/2.0+8.0,
            strokeWidth: 6.0,
            strokeColor: self.c1StrokeColor,
            progressColor: self.c1ActiveProgressColor
        )
        self.addChild(self.c1)
        self.c2 = Circle(
            radius: self.radius/2.0+8.0,
            strokeWidth: 6.0,
            strokeColor: .clear,
            progressColor: .clear
        )
        self.addChild(self.c2)
        self.c3 = Circle(
            radius: self.radius/2.0+8.0,
            strokeWidth: 6.0,
            strokeColor: .clear,
            progressColor: .clear
        )
        self.addChild(self.c3)

        // setup physics body
        self.physicsBody = LoopButton.generatePhysicBody(for: self.c1.radius)

        // set interaction active
        self.isUserInteractionEnabled = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tapAction()
    }

}

// MARK: - Actions

extension LoopButton {

    private func tapAction() {
        // SELF -> View
        self.onTapAction?(self.loopName)
    }

    func pendingStart(with duration: Double) {
        self.pendingAnimation(with: duration)
    }

    func pendingCancel() {
        self.pendingCancelAnimation()
    }

    func activate(with progressDuration: Double) {
        self.activateAnimation(with: progressDuration)
    }

    func deactivate() {
        self.idleAnimation()
    }

}

// MARK: - Animations

extension LoopButton {

    private func pendingAnimation(with duration: Double) {
        let newRadius = self.radius * (RADIUS_INCREASE/2)

        if let previousPendingCircle = self.pendingCircle {
            previousPendingCircle.removeFromParent()
        }

        self.pendingCircle = Circle(radius: 0.0, strokeWidth: 0.0, fillColor: .init(white: 1.0, alpha: 0.15))
        self.addChild(self.pendingCircle!)

        let resizeAnimation = self.pendingCircle!.radiusAnimation(radius: newRadius, duration: duration)
        self.pendingCircle!.run(resizeAnimation, completion: { [weak self] in
            self?.pendingCancelAnimation()
        })

        self.startIconBouncingAnimation()
    }

    private func pendingCancelAnimation() {

        // shot icon bouncing after 1 sec.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.stopIconBouncingAnimation()
        }

        if let pendingCircle = self.pendingCircle {
            let fadeOut = SKAction.fadeOut(withDuration: ANIMATION_TIME)
            fadeOut.timingMode = .easeOut
            pendingCircle.run(fadeOut) { [weak self] in
                pendingCircle.removeFromParent()
                self?.pendingCircle = nil
            }
        }

    }

    private func idleAnimation() {
        let newIconRadius = self.radius
        let newC1Radius = newIconRadius/2+8
        let newC2Radius = newIconRadius/2+8
        let newC3Radius = newIconRadius/2+8

        self.stopIconBouncingAnimation()
        self.stopProgressAction()

        // remove previous actions
        self.removeAllActions()
        self.icon.removeAllActions()

        // setup circles actions
        self.c1.strokeColor = self.c1StrokeColor
        let c1Radius = self.c1.radiusAnimation(radius: newC1Radius, duration: ANIMATION_TIME*2.0)
        let c1Stroke = self.c1.strokeWidthAnimation(width: 6.0, duration: ANIMATION_TIME*2.0)
        let c1Group = SKAction.group([c1Radius, c1Stroke])

        self.c2.progress = 0.0
        self.c2.strokeColor = .clear
        self.c2.removeAction(forKey: "c2Rotation")
        let c2Radius = self.c2.radiusAnimation(radius: newC2Radius, duration: ANIMATION_TIME*1.5)
        let c2Stroke = self.c2.strokeWidthAnimation(width: 1.0, duration: ANIMATION_TIME*1.5)
        let c2Group = SKAction.group([c2Radius, c2Stroke])

        self.c3.progress = 0.0
        self.c3.strokeColor = .clear
        self.c3.removeAction(forKey: "c3Rotation")
        let c3Radius = self.c3.radiusAnimation(radius: newC3Radius, duration: ANIMATION_TIME)
        let c3Stroke = self.c3.strokeWidthAnimation(width: 2.0, duration: ANIMATION_TIME)
        let c3Group = SKAction.group([c3Radius, c3Stroke])

        let circlesGroup = SKAction.group([c1Group, c2Group, c3Group])
        self.run(circlesGroup)

        // setup icon action
        self.icon.color = self.iconColorDefault
        self.icon.texture = SKTexture(image: UIImage(named: self.iconNameDefault)!)
        let iconSize = SKAction.resize(toWidth: newIconRadius, height: newIconRadius, duration: ANIMATION_TIME)
        self.icon.run(iconSize)

        let physicsAction = SKAction.customAction(withDuration: ANIMATION_TIME) { (_, elapsedTime) in
            let fraction = elapsedTime / CGFloat(ANIMATION_TIME) * (newC1Radius - self.physicRadius)
            self.physicRadius += fraction
        }
        self.run(physicsAction)

    }

    private func activateAnimation(with progressDuration: Double) {
        let newIconRadius = self.radius * RADIUS_INCREASE
        let newC1Radius = newIconRadius/2+28
        let newC2Radius = newIconRadius/2+20
        let newC3Radius = newIconRadius/2+9

        self.stopIconBouncingAnimation()

        // setup circles actions
        self.c1.strokeColor = self.c1ActiveStrokeColor
        let c1Radius = self.c1.radiusAnimation(radius: newC1Radius, duration: ANIMATION_TIME)
        let c1Stroke = self.c1.strokeWidthAnimation(width: 2.0, duration: ANIMATION_TIME)
        let c1Group = SKAction.group([c1Radius, c1Stroke])

        self.c2.progress = self.c2ActiveProgress
        self.c2.strokeColor = self.c2ActiveStrokeColor
        self.c2.progressColor = self.c2ActiveProgressColor
        let c2Radius = self.c2.radiusAnimation(radius: newC2Radius, duration: ANIMATION_TIME*1.5)
        let c2Stroke = self.c2.strokeWidthAnimation(width: 4.0, duration: ANIMATION_TIME*1.5)
        let c2Group = SKAction.group([c2Radius, c2Stroke])

        self.c3.progress = self.c3ActiveProgress
        self.c3.strokeColor = self.c3ActiveStrokeColor
        self.c3.progressColor = self.c3ActiveProgressColor
        let c3Radius = self.c3.radiusAnimation(radius: newC3Radius, duration: ANIMATION_TIME*2.0)
        let c3Stroke = self.c3.strokeWidthAnimation(width: 4.0, duration: ANIMATION_TIME*2.0)
        let c3Group = SKAction.group([c3Radius, c3Stroke])

        let circlesGroup = SKAction.group([c1Group, c2Group, c3Group])
        self.run(circlesGroup)

        // setup icon action
        self.icon.color = self.iconColorActive
        self.icon.texture = SKTexture(image: UIImage(named: self.iconNameActive)!)
        let iconSize = SKAction.resize(toWidth: newIconRadius, height: newIconRadius, duration: ANIMATION_TIME*2.5)
        self.icon.run(iconSize)

        // set circles rotation
        let c2Rotation = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi * 2), duration: ANIMATION_TIME*10.0))
        self.c2.run(c2Rotation, withKey: "c2Rotation")
        let c3Rotation = SKAction.repeatForever(SKAction.rotate(byAngle: -CGFloat(Double.pi * 2), duration: ANIMATION_TIME*10.0))
        self.c3.run(c3Rotation, withKey: "c3Rotation")

        self.startProgressAction(with: progressDuration)

        let physicsAction = SKAction.customAction(withDuration: ANIMATION_TIME) { (_, elapsedTime) in
            let fraction = elapsedTime / CGFloat(ANIMATION_TIME) * (newC1Radius - self.physicRadius)
            self.physicRadius += fraction
        }
        self.run(physicsAction)
    }

}

// MARK: - Atomic animations

extension LoopButton {

    private func startProgressAction(with duration: Double) {
        let c1Progress = SKAction.repeatForever(c1.progressAnimation(progress: 1.0, duration: duration))
        self.c1.run(c1Progress, withKey: "progressAction")
    }

    private func stopProgressAction() {
        self.c1.removeAction(forKey: "progressAction")
        self.c1.progress = 0.0
    }

    private func startIconBouncingAnimation() {
        if let _ = self.icon.action(forKey: "iconBouncing") { return }

        let iconActionUp = SKAction.move(by: CGVector(dx: 0, dy: 4), duration: ANIMATION_TIME)
        let iconActionDown = SKAction.move(by: CGVector(dx: 0, dy: -4), duration: ANIMATION_TIME)
        let iconBouncing = SKAction.repeatForever(SKAction.sequence([iconActionUp, iconActionDown]))
        self.icon.run(iconBouncing, withKey: "iconBouncing")
    }

    private func stopIconBouncingAnimation() {
        self.icon.removeAction(forKey: "iconBouncing")
        let moveIconToCenterAction = SKAction.move(to: .zero, duration: ANIMATION_TIME / 2)
        self.icon.run(moveIconToCenterAction)
    }
}

// MARK: - Utils

extension LoopButton {

    private static func generatePhysicBody(for radius: CGFloat) -> SKPhysicsBody {
        let p = SKPhysicsBody(circleOfRadius: radius + 5.0)
        p.allowsRotation = false
        p.restitution = 0.2
        p.linearDamping = 0.01
        p.friction = 0.0
        return p
    }

}
