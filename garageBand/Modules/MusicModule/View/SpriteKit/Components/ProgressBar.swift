//
//  ProgressBar.swift
//  garageBand
//
//  Created by mark on 11/02/2022.
//  Copyright © 2022 mark All rights reserved.
//

import SpriteKit

typealias ProgressBarMarkerPosition = LoopButtonPosition

class ProgressBar: SKShapeNode {
    
    var size: CGSize!
    var progress: CGFloat! {
        didSet {
            if progress <= 0.0 || progress > 1.0 { return }
            
            self.pin.position = CGPoint(x: self.size.width*progress, y: self.centerY)
            self.line1.path = self.line1Path
            self.line2.path = self.line2Path
            if self.currentWave1Amplitude == 0.0 {
                self.bassWave.path = self.bassWaveDefaultLinePath
            }
            if self.currentWave2Amplitude == 0.0 {
                self.leadWave.path = self.leadWaveDefaultLinePath
            }
        }
    }
    private var leadProgressBarColor: SKColor!
    private var bassProgressBarColor: SKColor!
    
    private var centerY: CGFloat { return self.size.height / 2 }
    private var markerContainer: MarkerContainer!
    private var strokeWith: CGFloat { return 3.0 }  // this could be calculated according size
    private lazy var pin: SKNode = {
        let c = SKShapeNode(rectOf: CGSize(width: 10, height: self.size.height))
        c.strokeColor = .clear
        c.position = CGPoint(x: self.size.width*progress, y: self.centerY)

        let c1 = Circle(radius: self.strokeWith, strokeColor: .clear, fillColor: self.leadProgressBarColor)
        c.addChild(c1)
        c1.position = CGPoint(x: c1.position.x, y: c1.position.y+c1.radius)

        let c2 = Circle(radius: self.strokeWith, strokeColor: .clear, fillColor: self.bassProgressBarColor)
        c.addChild(c2)
        c2.position = CGPoint(x: c2.position.x, y: c2.position.y-c2.radius)

        return c
    }()
    private var currentWave1Amplitude: Double = 0.0
    private var currentWave2Amplitude: Double = 0.0
    private var line1Path: CGPath {
        let p = CGMutablePath()
        let startPoint = CGPoint(x: 0, y: self.centerY+self.strokeWith)
        let endPoint = CGPoint(x: self.size.width*progress, y: self.centerY+self.strokeWith)
        p.addLines(between: [startPoint, endPoint])
        return p
    }
    private var line2Path: CGPath {
        let p = CGMutablePath()
        let startPoint = CGPoint(x: 0, y: self.centerY-self.strokeWith)
        let endPoint = CGPoint(x: self.size.width*progress, y: self.centerY-self.strokeWith)
        p.addLines(between: [startPoint, endPoint])
        return p
    }
    private var bassWaveDefaultLinePath: CGPath {
        let p = CGMutablePath()
        let startPoint = CGPoint(x: self.size.width*progress, y: self.centerY-self.strokeWith)
        let endPoint = CGPoint(x: self.size.width, y: self.centerY-self.strokeWith)
        p.addLines(between: [startPoint, endPoint])
        return p
    }
    private var leadWaveDefaultLinePath: CGPath {
        let p = CGMutablePath()
        let startPoint = CGPoint(x: self.size.width*progress, y: self.centerY+self.strokeWith)
        let endPoint = CGPoint(x: self.size.width, y: self.centerY+self.strokeWith)
        p.addLines(between: [startPoint, endPoint])
        return p
    }
    
    private lazy var line1: SKShapeNode = {
        let l = SKShapeNode()
        l.lineWidth = self.strokeWith
        l.path = self.line1Path
        l.strokeColor = self.leadProgressBarColor
        return l
    }()
    private lazy var line2: SKShapeNode = {
        let l = SKShapeNode()
        l.lineWidth = self.strokeWith
        l.path = self.line2Path
        l.strokeColor = self.bassProgressBarColor
        return l
    }()
    private lazy var bassWave: SKShapeNode = {
        let l = SKShapeNode()
        l.lineWidth = self.strokeWith
        l.path = self.bassWaveDefaultLinePath
        l.strokeColor = self.bassProgressBarColor
        return l
    }()
    private lazy var leadWave: SKShapeNode = {
        let l = SKShapeNode()
        l.lineWidth = self.strokeWith
        l.path = self.leadWaveDefaultLinePath
        l.strokeColor = self.leadProgressBarColor
        return l
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize, barsCount: Int, leadProgressBarColor: SKColor?, bassProgressBarColor: SKColor?) {
        super.init()
        
        // setup self
        self.size = size
        self.progress = 0.0
        self.leadProgressBarColor = leadProgressBarColor
        self.bassProgressBarColor = bassProgressBarColor
        self.path = CGPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), transform: nil)
        self.strokeColor = .clear
        
//        // setup markers container VARIANT 1: limited levels but icons can be smaller
//        let MAX_LEVELS_COUNT: CGFloat = 5.0
//        func calculateLevelsCount(screenWidth: CGFloat, barsCount: CGFloat, targetWidth: CGFloat) -> Int {
//            let segmentsCount = screenWidth / targetWidth
//            let levelsCount = barsCount / segmentsCount
//            if levelsCount <= MAX_LEVELS_COUNT {
//                return Int(levelsCount.rounded(.up))
//            }
//
//            return calculateLevelsCount(screenWidth: screenWidth, barsCount: barsCount, targetWidth: targetWidth-1)
//        }
//        let segmentsCount = barsCount.cgFloat / calculateLevelsCount(screenWidth: size.width, barsCount: barsCount.cgFloat, targetWidth: 14.0).cgFloat
//        self.markerContainer = MarkerContainer(size: size, segmentsCount: segmentsCount.int)
//        self.addChild(self.markerContainer)

        // setup markers container VARIANT 2: fixed icons size but unlimited levels
        let TARGET_WIDTH: CGFloat = 14.0
        let segmentsCount = size.width / TARGET_WIDTH
        self.markerContainer = MarkerContainer(size: size, segmentsCount: segmentsCount.int)
        self.addChild(self.markerContainer)

        // setup elements
        self.addChild(self.line1)
        self.addChild(self.line2)
        self.addChild(self.bassWave)
        self.addChild(self.leadWave)
        self.addChild(self.pin)
                
    }
    
}

// MARK: Action

extension ProgressBar {
    
    func showWaveWithAmplitude(for leadAmplitude: Double, for bassAmplitude: Double) {

        // lead wave
        if leadAmplitude > 0 {
            self.currentWave2Amplitude = leadAmplitude
            let amp: CGFloat = CGFloat(leadAmplitude) * 500.0   // 250 < ??? < 1000
            let freq: CGFloat = 50

            let y = self.centerY + self.strokeWith
            let start = CGPoint(x: self.size.width*progress, y: y)
            let end = CGPoint(x: self.size.width, y: y)
            var points = [CGPoint]()

            if freq > 0 {
                for i in 1...freq.int {
                    let x = start.x + 30 * i.cgFloat
                    let y = y - sin(x) * amp * i.cgFloat/freq
                    let p = CGPoint(x: x, y: y)
                    points.append(p)
                }
            }
            points.insert(start, at: 0)
            points.append(end)

            self.leadWave.path = self.quadCurve(with: points)
        } else {
            self.currentWave2Amplitude = 0.0
        }

        // bass wave
        if bassAmplitude > 0 {
            self.currentWave1Amplitude = bassAmplitude
            let amp: CGFloat = CGFloat(bassAmplitude) * 500.0   // 250 < ??? < 1000
            let freq: CGFloat = 50

            let y = self.centerY - self.strokeWith
            let start = CGPoint(x: self.size.width*progress, y: y)
            let end = CGPoint(x: self.size.width, y: y)
            var points = [CGPoint]()

            if freq > 0 {
                for i in 1...freq.int {
                    let x = start.x + 30 * i.cgFloat
                    let y = y + sin(x) * amp * i.cgFloat/freq
                    let p = CGPoint(x: x, y: y)
                    points.append(p)
                }
            }
            points.insert(start, at: 0)
            points.append(end)

            self.bassWave.path = self.quadCurve(with: points)
        } else {
            self.currentWave1Amplitude = 0.0
        }

    }
    
    func showProgress(with progress: CGFloat, animation duration: Double) {
        if progress < 0 || progress > 1.0 { return }
        
        let progressDelta: Double = Double(progress - self.progress)
        var previousTimeFraction: Double = 0.0
        let p = SKAction.customAction(withDuration: duration) { (n, elapsedTime) in
            let timeFraction: Double = Double(elapsedTime) / duration
            let progressToSet = CGFloat(progressDelta * timeFraction) - CGFloat(progressDelta * previousTimeFraction)
            self.progress += progressToSet
            previousTimeFraction = timeFraction
        }
        self.pin.run(p)
    }
    
    func addMarker(with iconName: String, with markerPosition: ProgressBarMarkerPosition) {
        
        var markerColor: SKColor
        
        switch markerPosition {
        case .top:
            markerColor = self.leadProgressBarColor
        case .bottom:
            markerColor = self.bassProgressBarColor
        }
        
        self.markerContainer.addMarker(with: iconName, at: self.progress, position: markerPosition, color: markerColor)
    }
    
}

// MARK: Utils

extension ProgressBar {
    
    private func quadCurve(with points: [CGPoint]) -> CGPath {
        let bezierPath = UIBezierPath()
        var prevPoint: CGPoint?
        var isFirst = true
        
        for point in points {
            if let prevPoint = prevPoint {
                let midPoint = CGPoint(
                    x: (point.x + prevPoint.x) / 2,
                    y: (point.y + prevPoint.y) / 2)
                if isFirst {
                    bezierPath.addLine(to: midPoint)
                }
                else {
                    bezierPath.addQuadCurve(to: midPoint, controlPoint: prevPoint)
                }
                isFirst = false
            }
            else {
                bezierPath.move(to: point)
            }
            prevPoint = point
        }
        if let prevPoint = prevPoint {
            bezierPath.addLine(to: prevPoint)
        }
        
        return bezierPath.cgPath
    }
    
}

// MARK: - MarkerContainer class implementation

private class MarkerContainer: SKShapeNode {
    
    private var size: CGSize!
    private var segments: [Segment] {
        return self.children.compactMap({ $0 as? Segment })
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(size: CGSize, segmentsCount: Int) {
        super.init()
        
        // setup self
        self.size = size
        
        let segmentWidth = size.width/segmentsCount.cgFloat
        
        for i in 0..<segmentsCount {
            let segment = Segment(size: CGSize(width: segmentWidth, height: size.height))
            segment.position = CGPoint(x: segmentWidth*i.cgFloat, y: self.position.y)
            self.addChild(segment)
        }
    }
    
    func addMarker(with name: String, at progress: CGFloat, position: ProgressBarMarkerPosition, color: SKColor) {
        let currentXPosition = self.size.width * progress
        let progressPoint = CGPoint(x: currentXPosition, y: self.size.height/2)
        
        let segment = self.findSegment(at: progressPoint)
        segment?.addMarker(with: name, at: position, color: color)

        if App.Settings.isDebug {
            self.segments.forEach({ $0.fillColor = .clear })
            segment?.fillColor = SKColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
        }
        
    }
    
    private func findSegment(at point: CGPoint) -> Segment? {
        let segment = self.segments.first(where: { $0.frame.contains(point) })
        return segment
    }
    
}

// MARK: - Segment class implementation

private class Segment: SKShapeNode {
    
    private var size: CGSize!
    private var itemSize: CGSize {
        var width = self.size.width
        if width > 12 { width = 12 }
        width = width.rounded(.down)
        return CGSize(width: width, height: width)
    }
    private var centerX: CGFloat { return self.size.width / 2 }
    private var topItems = [SKSpriteNode]()
    private var bottomItems = [SKSpriteNode]()

    private var topLine: SKShapeNode?
    private var topLineEndPointY: CGFloat!
    private var bottomLine: SKShapeNode?
    private var bottomLineEndPointY: CGFloat!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize) {
        super.init()
        
        // setup self
        self.size = size
        self.path = CGPath(
            rect: CGRect(size: size), 
            transform: nil
        )
        
        if App.Settings.isDebug {
            self.strokeColor = .red
        } else {
            self.strokeColor = .clear
        }
    }
    
    func addMarker(with name: String, at position: ProgressBarMarkerPosition, color: SKColor) {
        switch position {
        case .top:

            // setup topLine if needed
            if self.topLine == nil {
                // setup topLine path
                let p = CGMutablePath()
                let startPoint = CGPoint(x: self.centerX, y: self.size.height/2+3)  // 3px offset
                let endPoint = CGPoint(x: self.centerX, y: (self.size.height/2+3) + (self.itemSize.height/2))
                self.topLineEndPointY = endPoint.y
                p.addLines(between: [startPoint, endPoint])

                // setup topLine
                let l = SKShapeNode()
                l.strokeColor = color
                l.lineWidth = 1
                l.path = p
                self.addChild(l)

                self.topLine = l
            }

            // create new item
            let i = SKSpriteNode(imageNamed: name)
            i.size = self.itemSize
            i.colorBlendFactor = 1.0
            i.color = color
            i.alpha = 0.0
            i.position = CGPoint(x: self.centerX, y: self.topLineEndPointY+self.itemSize.height*self.topItems.count.cgFloat+(self.itemSize.height/2)+1+4)
            self.addChild(i)
            self.topItems.insert(i, at: 0)

            // animate new item
            let moveAction = SKAction.moveTo(y: i.position.y - 4, duration: 0.2)
            moveAction.timingMode = .easeInEaseOut
            i.run(SKAction.group([
                SKAction.fadeIn(withDuration: 0.2),
                moveAction
            ]))
            
        case .bottom:

            // setup bottomLine if needed
            if self.bottomLine == nil {
                // setup topLine path
                let p = CGMutablePath()
                let startPoint = CGPoint(x: self.centerX, y: self.size.height/2-3)  // -3px offset
                let endPoint = CGPoint(x: self.centerX, y: (self.size.height/2-3) - (self.itemSize.height/2))
                self.bottomLineEndPointY = endPoint.y
                p.addLines(between: [startPoint, endPoint])

                // setup bottomLine
                let l = SKShapeNode()
                l.strokeColor = color
                l.lineWidth = 1
                l.path = p
                self.addChild(l)

                self.bottomLine = l
            }

            // create new item
            let i = SKSpriteNode(imageNamed: name)
            i.size = self.itemSize
            i.colorBlendFactor = 1.0
            i.color = color
            i.alpha = 0.0
            i.position = CGPoint(x: self.centerX, y: self.bottomLineEndPointY-self.itemSize.height*self.bottomItems.count.cgFloat-(self.itemSize.height/2)-1-4)
            self.addChild(i)
            self.bottomItems.insert(i, at: 0)

            // animate new item
            let moveAction = SKAction.moveTo(y: i.position.y + 4, duration: 0.2)
            moveAction.timingMode = .easeInEaseOut
            i.run(SKAction.group([
                SKAction.fadeIn(withDuration: 0.2),
                moveAction
            ]))

        }
    }
    
}
