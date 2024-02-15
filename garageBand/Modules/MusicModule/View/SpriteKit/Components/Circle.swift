//
//  Circle.swift
//  garageBand
//
//  Created by mark on 02/02/2022.
//  Copyright © 2022 mark All rights reserved.
//

import SpriteKit


class Circle: SKNode {
    
    var radius: CGFloat = 0.0 {
        didSet {
            self.backgroundCircle.path = Circle.path(radius: radius)
            self.progressCircle.path = Circle.path(radius: radius, progress: self.progress)
        }
    }
    var strokeWidth: CGFloat = 0.0 {
        didSet {
            self.backgroundCircle.lineWidth = strokeWidth
            self.progressCircle.lineWidth = strokeWidth
        }
    }
    var strokeColor: SKColor = .white {
        didSet {
            self.backgroundCircle.strokeColor = strokeColor
        }
    }
    var fillColor: SKColor = .clear {
        didSet {
            self.backgroundCircle.fillColor = fillColor
        }
    }
    var progressColor: SKColor = .clear {
        didSet {
            self.progressCircle.strokeColor = progressColor
        }
    }
    var progress: CGFloat = 0.0 {
        didSet {
            self.progressCircle.path = Circle.path(radius: self.radius, progress: progress)
        }
    }
    
    private var backgroundCircle: SKShapeNode!
    private var progressCircle: SKShapeNode!
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(
        radius: CGFloat = 100.0,
        strokeWidth: CGFloat = 1.0,
        strokeColor: SKColor = .white,
        fillColor: SKColor = .clear,
        progress: CGFloat = 0.0,
        progressColor: SKColor = .red
        ) {
        super.init()
        
        // setup self
        self.radius = radius
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.fillColor = fillColor
        self.progress = progress
        
        // setup background circle
        self.backgroundCircle = SKShapeNode(path: Circle.path(radius: radius))
        self.backgroundCircle.strokeColor = strokeColor
        self.backgroundCircle.fillColor = fillColor
        self.backgroundCircle.lineWidth = strokeWidth
        self.addChild(self.backgroundCircle)
        
        // setup progress circle
        self.progressCircle = SKShapeNode(path: Circle.path(radius: radius, progress: progress))
        self.progressCircle.strokeColor = progressColor
        self.progressCircle.lineWidth = strokeWidth
        self.addChild(self.progressCircle)
        
    }
    
    func radiusAnimation(radius: CGFloat, duration: Double = 1.0) -> SKAction {
        let delta = radius - self.radius
        var previousFtaction: CGFloat = 0.0
        let a = SKAction.customAction(withDuration: duration) { (_, elapsedTime) in
            let timeFraction = elapsedTime / CGFloat(duration)
            let radiusFraction = timeFraction * delta - previousFtaction * delta
            self.radius += radiusFraction
            previousFtaction = timeFraction
        }
        return a
    }
    
    func strokeWidthAnimation(width: CGFloat, duration: Double = 1.0) -> SKAction {
        let delta = width - self.strokeWidth
        var previousFtaction: CGFloat = 0.0
        let a = SKAction.customAction(withDuration: duration) { (_, elapsedTime) in
            let timeFraction = elapsedTime / CGFloat(duration)
            let widthFraction = timeFraction * delta - previousFtaction * delta
            self.strokeWidth += widthFraction
            previousFtaction = timeFraction
        }
        return a
    }
    
    func progressAnimation(progress: CGFloat, duration: Double = 1.0) -> SKAction {
        let a = SKAction.customAction(withDuration: duration) { (_, elapsedTime) in
            let fraction = elapsedTime / CGFloat(duration) * progress
            self.progress = fraction
        }
        return a
    }
    
}

// MARK: Utils

private extension Circle {
    
    static func path(radius: CGFloat, progress: CGFloat? = nil) -> CGMutablePath {
        let path: CGMutablePath = CGMutablePath()
        
        var startAngle: CGFloat = 0.0
        var endAngle = CGFloat(2.0*Double.pi)
        if let progress = progress {
            let progress = 1.0 - progress
            startAngle = CGFloat(Double.pi / 2.0)
            endAngle = startAngle + progress * CGFloat(2.0*Double.pi)
        }
        
        path.addArc(
            center: CGPoint(x: 0, y: 0),
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true)
        
        return path
    }
    
}
