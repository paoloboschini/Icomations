//
//  Icomation.swift
//  Icomations
//
//  Created by Paolo Boschini on 28/04/15.
//  Copyright (c) 2015 Paolo Boschini. All rights reserved.
//

import UIKit

extension CAAnimation {
    func setUp(duration: Double) {
        self.fillMode = kCAFillModeForwards
        self.removedOnCompletion = false
        self.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.duration = CFTimeInterval(duration)
    }
}

enum IconType {
    case ArrowUp, ArrowLeft, ArrowDown, ArrowRight, SmallArrowUp, SmallArrowLeft, SmallArrowDown, SmallArrowRight, Close, SmallClose
}

class Icomation: UIButton {
    
    private enum IconState {
        case Hamburger, Arrow, Close
    }

    private var toggleState = true
    private var topAnimation, middleAnimation, bottomAnimation: CAAnimation!
    private var halfSideOfTriangle: CGFloat!
    private var w, h, lineWidth: CGFloat!

    var topShape, middleShape, bottomShape: CAShapeLayer!
    var animationDuration = 1.0
    var numberOfRotations: Double = 0
    var type: IconType!

    override init(frame: CGRect) {
        super.init(frame: frame)
        create()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        create()
    }
    
    private func create() {
        type = IconType.self.SmallArrowLeft
        
        titleLabel?.text = ""
        backgroundColor = UIColor.clearColor()
        let strokeColor = UIColor.whiteColor()
        
        w = bounds.width
        h = bounds.height
        lineWidth = 3
        
        let hypotenuse = w/2
        halfSideOfTriangle = (hypotenuse / sqrt(2)) / 2
        
        var path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: w, y: 0))
        
        topShape = shapeLayer(path.CGPath, position: CGPoint(x: w/2, y: h/4), color: strokeColor)
        topShape.bounds = CGPathGetBoundingBox(topShape.path)
        
        middleShape = shapeLayer(path.CGPath, position: CGPoint(x: w/2, y: h/2), color: strokeColor)
        middleShape.bounds = CGPathGetBoundingBox(middleShape.path)
        
        bottomShape = shapeLayer(path.CGPath, position: CGPoint(x: w/2, y: h-h/4), color: strokeColor)
        bottomShape.bounds = CGPathGetBoundingBox(bottomShape.path)
        
        layer.addSublayer(topShape)
        layer.addSublayer(middleShape)
        layer.addSublayer(bottomShape)
    }
    
    // MARK: - Shapes
    
    private func shapeLayer(path: CGPath, position: CGPoint, color: UIColor) -> CAShapeLayer{
        let s = CAShapeLayer()
        s.lineWidth = lineWidth
        s.lineCap = kCALineCapRound
        s.strokeColor = color.CGColor
        s.path = path
        s.position = position
        return s
    }
    
    // MARK: - Animations
    
    private func basicAnimation(keyPath: String, from: CGFloat = -1, to: CGFloat = -1, byValue: CGFloat = -1) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: keyPath)
        if from != -1 { a.fromValue = from }
        if to != -1 { a.toValue = to }
        if byValue != -1 { a.byValue = byValue }
        return a
    }
    
    private func groupAnimation(type: IconState, x: CGFloat = 0, y: CGFloat = 0, r: CGFloat = 0, s: CGFloat = 0.5) -> CAAnimation {
        
        var xa, ya, ra, sa: CABasicAnimation!
        
        if type == IconState.Arrow || type == IconState.Close {
            xa = basicAnimation("transform.translation.x", from: 0, to: x)
            ya = basicAnimation("transform.translation.y", from: 0, to: y)
            ra = basicAnimation("transform.rotation.z", from: 0, to: r)
            sa = basicAnimation("transform.scale.x", byValue: -s)
        }
        
        if type == IconState.Hamburger {
            xa = basicAnimation("transform.translation.x", from: x, to: 0)
            ya = basicAnimation("transform.translation.y", from: y, to: 0)
            ra = basicAnimation("transform.rotation.z", from: r, to: 0)
            sa = basicAnimation("transform.scale.x", byValue: s)
        }
        
        let group = CAAnimationGroup()
        group.setUp(animationDuration)
        group.animations = [xa, ya, ra, sa]
        return group
    }
    
    private func rotate(type: IconState, to: CGFloat) -> CAAnimation {
        var r: CABasicAnimation!
        if type == IconState.Arrow {
            r = basicAnimation("transform.rotation.z", from: 0, to: to)
        }
        if type == IconState.Hamburger {
            r = basicAnimation("transform.rotation.z", from: to, to: 0)
        }
        r.setUp(animationDuration)
        return r
    }
    
    private func shrinkToDisappear(type: IconState) -> CAAnimation {
        let value: CGFloat = type == IconState.Close ? -0.999 : 1.0
        let s = basicAnimation("transform.scale.x", byValue: value)
        s.setUp(animationDuration)
        return s
    }
    
    private func addAnimations() {
        topShape.addAnimation(topAnimation, forKey:"")
        middleShape.addAnimation(middleAnimation, forKey:"")
        bottomShape.addAnimation(bottomAnimation, forKey:"")
    }

    // MARK: - Toggles
    
    private func arrowLeft() {
        let buttonType = toggleState ? IconState.Arrow : IconState.Hamburger
        
        let topRotation = CGFloat(-M_PI * (3/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: halfSideOfTriangle - w/2, y: halfSideOfTriangle + h/4, r: topRotation)
        
        let middleRotation = CGFloat(-M_PI * (numberOfRotations + 1))
        middleAnimation = rotate(buttonType, to: middleRotation)
        
        let bottomRotation = CGFloat(-M_PI * (5/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: halfSideOfTriangle - w/2, y: -h/4 - halfSideOfTriangle, r: bottomRotation)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    private func smallArrowLeft() {
        let buttonType = toggleState ? IconState.Arrow : IconState.Hamburger
        
        let topRotation = CGFloat(-M_PI * (3/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: -halfSideOfTriangle + 1, y: (halfSideOfTriangle/2) + h/4, r: topRotation, s: 3/4)
        
        let middleRotation = CGFloat(-M_PI * (numberOfRotations + 1))
        middleAnimation = groupAnimation(buttonType, r: middleRotation)
        
        let bottomRotation = CGFloat(-M_PI * (5/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: -halfSideOfTriangle + 1, y: -h/4 - (halfSideOfTriangle/2), r: bottomRotation, s: 3/4)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    private func arrowUp() {
        let buttonType = toggleState ? IconState.Arrow : IconState.Hamburger
        
        let topRotation = CGFloat(-M_PI * (3/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: halfSideOfTriangle, y: 0 - halfSideOfTriangle/2, r: topRotation)
        
        var add: CGFloat!
        if numberOfRotations == 0 {
            add = 0
        } else if numberOfRotations % 2 == 0 {
            add = CGFloat(-M_PI)
        } else {
            add = CGFloat(-M_PI/2)
        }
        let middleRotation = CGFloat(add - CGFloat(M_PI/2) * CGFloat(numberOfRotations + 1))
        middleAnimation = rotate(buttonType, to: middleRotation)
        
        let bottomRotation = CGFloat(-M_PI * (1/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: -halfSideOfTriangle, y: -h/2 - halfSideOfTriangle/2, r: bottomRotation)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    private func smallArrowUp() {
        let buttonType = toggleState ? IconState.Arrow : IconState.Hamburger
        
        let topRotation = CGFloat(-M_PI * (3/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: halfSideOfTriangle/2, y: halfSideOfTriangle/2 - 1, r: topRotation, s: 3/4)
        
        var add: CGFloat!
        if numberOfRotations == 0 {
            add = 0
        } else if numberOfRotations % 2 == 0 {
            add = CGFloat(-M_PI)
        } else {
            add = CGFloat(-M_PI/2)
        }
        let middleRotation = CGFloat(add - CGFloat(M_PI/2) * CGFloat(numberOfRotations + 1))
        middleAnimation = groupAnimation(buttonType, r: middleRotation)
        
        let bottomRotation = CGFloat(-M_PI * (1/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: -halfSideOfTriangle/2, y: -w/2 + halfSideOfTriangle/2 - 1, r: bottomRotation, s: 3/4)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    private func arrowDown() {
        let buttonType = toggleState ? IconState.Arrow : IconState.Hamburger
        
        let topRotation = CGFloat(M_PI * (3/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: halfSideOfTriangle, y: h/2 + halfSideOfTriangle/2 - 1, r: topRotation)
        
        var add: CGFloat!
        if numberOfRotations == 0 {
            add = 0
        } else if numberOfRotations % 2 == 0 {
            add = CGFloat(M_PI)
        } else {
            add = CGFloat(M_PI/2)
        }
        let middleRotation = CGFloat(add + CGFloat(M_PI/2) * CGFloat(numberOfRotations + 1))
        middleAnimation = rotate(buttonType, to: middleRotation)
        
        let bottomRotation = CGFloat(M_PI * (1/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: -halfSideOfTriangle, y: halfSideOfTriangle/2 - 1, r: bottomRotation)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    private func smallArrowDown() {
        let buttonType = toggleState ? IconState.Arrow : IconState.Hamburger
        
        let topRotation = CGFloat(M_PI * (1/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: -halfSideOfTriangle/2, y: w/2 - halfSideOfTriangle/2, r: topRotation, s: 3/4)
        
        var add: CGFloat!
        if numberOfRotations == 0 {
            add = 0
        } else if numberOfRotations % 2 == 0 {
            add = CGFloat(M_PI)
        } else {
            add = CGFloat(M_PI/2)
        }
        let middleRotation = CGFloat(add + CGFloat(M_PI/2) * CGFloat(numberOfRotations + 1))
        middleAnimation = groupAnimation(buttonType, r: middleRotation)
        
        let bottomRotation = CGFloat(M_PI * (3/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: halfSideOfTriangle/2, y: -halfSideOfTriangle/2, r: bottomRotation, s: 3/4)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    private func arrowRight() {
        let buttonType = toggleState ? IconState.Arrow : IconState.Hamburger
        
        let topRotation = CGFloat(M_PI * (3/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: w/2 - halfSideOfTriangle, y: halfSideOfTriangle + h/4, r: topRotation)
        
        let middleRotation = CGFloat(M_PI * (numberOfRotations + 1))
        middleAnimation = rotate(buttonType, to: middleRotation)
        
        let bottomRotation = CGFloat(M_PI * (5/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: w/2 - halfSideOfTriangle, y: -h/4 - halfSideOfTriangle, r: bottomRotation)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    private func smallArrowRight() {
        let buttonType = toggleState ? IconState.Arrow : IconState.Hamburger
        
        let topRotation = CGFloat(M_PI * (3/4 + numberOfRotations))
        topAnimation = groupAnimation(buttonType, x: halfSideOfTriangle - 1, y: (halfSideOfTriangle/2) + h/4, r: topRotation, s: 3/4)
        
        let middleRotation = CGFloat(M_PI * (numberOfRotations + 1))
        middleAnimation = groupAnimation(buttonType, r: middleRotation)
        
        let bottomRotation = CGFloat(M_PI * (5/4 + numberOfRotations))
        bottomAnimation = groupAnimation(buttonType, x: halfSideOfTriangle - 1, y: (-halfSideOfTriangle/2) - h/4, r: bottomRotation, s: 3/4)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    private func close() {
        let buttonType = toggleState ? IconState.Close : IconState.Hamburger
        
        topAnimation = groupAnimation(buttonType, y: h/4, r: CGFloat(M_PI * (3/4 + numberOfRotations)), s: 0)
        middleAnimation = shrinkToDisappear(buttonType)
        bottomAnimation = groupAnimation(buttonType, y: -h/4, r: CGFloat(M_PI * (5/4 + numberOfRotations)), s: 0)
        
        addAnimations()
        toggleState = !toggleState
    }
    
    private func smallClose() {
        let buttonType = toggleState ? IconState.Close : IconState.Hamburger
        
        topAnimation = groupAnimation(buttonType, y: h/4, r: CGFloat(M_PI * (3/4 + numberOfRotations)))
        middleAnimation = shrinkToDisappear(buttonType)
        bottomAnimation = groupAnimation(buttonType, y: -h/4, r: CGFloat(M_PI * (5/4 + numberOfRotations)))
        
        addAnimations()
        toggleState = !toggleState
    }
    
    // MARK: - Touch Gestures
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(0.8, 0.8)
        })
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.0, 1.0)
            switch self.type {
            case IconType.self.ArrowUp: self.arrowUp()
            case IconType.self.ArrowLeft: self.arrowLeft()
            case IconType.self.ArrowDown: self.arrowDown()
            case IconType.self.ArrowRight: self.arrowRight()
            case IconType.self.Close: self.close()
            case IconType.self.SmallArrowUp: self.smallArrowUp()
            case IconType.self.SmallArrowLeft: self.smallArrowLeft()
            case IconType.self.SmallArrowDown: self.smallArrowDown()
            case IconType.self.SmallArrowRight: self.smallArrowRight()
            case IconType.self.SmallClose: self.smallClose()
            default: self.close()
            }
        })
    }
}