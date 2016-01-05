//
//  AnimationFactory.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 1/3/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class AnimationFactory: ActivityIndicatorProtocol {
    
    func configureAnimation(inlayer layer: CALayer, withSize size: CGFloat) {
        let spacing: CGFloat = 5.0
        let sizeOfDot = (size - 2 * spacing) / 3
        let dot = CAShapeLayer()
        
        dot.frame = CGRect(x: 0, y: (size - sizeOfDot) / 2, width: sizeOfDot, height: sizeOfDot)
        dot.path = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: sizeOfDot, height: sizeOfDot)).CGPath
        dot.fillColor = UIColor.whiteColor().CGColor
        
        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.frame = CGRect(x: 0, y: 0, width: size, height: size)
        
        replicatorLayer.instanceDelay = 0.2
        replicatorLayer.instanceCount = 3
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation(spacing + sizeOfDot, 0, 0)
        
        replicatorLayer.addSublayer(dot)
        layer.addSublayer(replicatorLayer)
        dot.addAnimation(createDotAnimation(), forKey: "scaleAnimation")
    }
    
    func createDotAnimation() -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "transform")

        let valueFrom = NSValue.init(CATransform3D: CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 0.0))
        let valueTo = NSValue.init(CATransform3D: CATransform3DScale(CATransform3DIdentity, 0.2, 0.2, 0.0))
        
        animation.fromValue = valueFrom
        animation.toValue = valueTo
        
        animation.autoreverses = true
        
        animation.repeatCount = HUGE
        
        animation.duration = 0.3
        
        return animation
        
    }
}