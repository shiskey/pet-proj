//
//  LoopArea.swift
//  garageBand
//
//  Created by mark on 10/02/2022.
//  Copyright © 2022 mark All rights reserved.
//

import SpriteKit

class LoopArea: SKShapeNode {
    
    private var size: CGSize!
    private var buttons: [LoopButton] {
        return self.children.compactMap { $0 as? LoopButton }
    }
    private var positionForNewButton: CGPoint {
        return self.calculateGravityPoints(for: self.buttons.count).last ?? .zero
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize) {
        super.init()
        
        self.size = size
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: .init(x: 0, y: 0, width: size.width-1, height: size.height))
    }
    
}

// MARK: Actions

extension LoopArea {
    
    func add(button: LoopButton) {
        self.addChild(button)
        button.position = self.positionForNewButton
        button.alpha = 0.0
        button.run(SKAction.fadeIn(withDuration: 0.8))
        
        self.calculateGravity()
    }
    
    func remove(button: LoopButton) {
        button.isUserInteractionEnabled = false
        button.run(SKAction.fadeOut(withDuration: 0.8)) {
            button.removeFromParent()
        }
    }
    
    func calculateGravity() {
        
        if App.Settings.isDebug {
            let c = self.children.compactMap { $0 as? SKShapeNode }
            c.forEach { $0.removeFromParent() }
        }
        
        let points = self.calculateGravityPoints(for: self.buttons.count)
        let a = zip(self.buttons, points)
        a.forEach { (b, p) in
            
            if App.Settings.isDebug {
                let n = SKShapeNode(circleOfRadius: 5.0)
                n.fillColor = .red
                n.strokeColor = .clear
                n.position = p
                self.addChild(n)
            }
            
            let v = CGVector(dx: p.x-b.position.x, dy: p.y-b.position.y)
            b.physicsBody?.applyForce(v)
        }

    }
    
    func throwawayButtons() {
        
        for b in self.buttons {

            let scene = self.scene!
            let centerScene = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
            
            if App.Settings.isDebug {
                let line: SKShapeNode = {
                    let l = SKShapeNode()
                    let p = CGMutablePath()
                    p.addLines(between: [centerScene, b.positionInScene!])
                    l.path = path
                    l.strokeColor = .red
                    l.lineWidth = 2
                    return l
                }()
                scene.addChild(line)
            }
            
            let throwawayAction = SKAction.move(by: CGVector(
                dx: (centerScene.x-b.positionInScene!.x) * -1.5,
                dy: (centerScene.y-b.positionInScene!.y) * -1.5
            ), duration: 4.0)
            let fadeOutAction = SKAction.fadeOut(withDuration: 4.0)
            b.run(SKAction.group([throwawayAction, fadeOutAction]), completion: { 
                b.removeFromParent()
            })
            
            // remove self physic body
            self.physicsBody = nil
        }
        
    }
    
}

// MARK: Utils

extension LoopArea {
    
    private func calculateGravityPoints(for buttonsCount: Int) -> [CGPoint] {
        var points = [CGPoint]()
        if buttonsCount == 0 { return points }

        for i in 1...buttonsCount {
            var fY: CGFloat = 0.0
            if i % 3 == 0 { fY = 0.25 }
            if i % 3 == 1 { fY = 0.5 }
            if i % 3 == 2 { fY = 0.75 }
            let x = self.size.width * (i.cgFloat/(buttonsCount.cgFloat + 1))
            let y = self.size.height * fY
            
            let rX = CGFloat.random(in: -20...20)
            let rY = CGFloat.random(in: -20...20)
            
            points.append(CGPoint(x: x+rX, y: y+rY))
        }

        return points
    }
    
}
