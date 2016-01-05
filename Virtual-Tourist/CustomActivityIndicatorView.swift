//
//  CustomActivityIndicatorView.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 1/3/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

protocol ActivityIndicatorProtocol {
    func configureAnimation(inlayer layer: CALayer, withSize: CGFloat)
}

/* Custom activity indicator view */
class CustomActivityIndicatorView: UIView {
    let animation: ActivityIndicatorProtocol = AnimationFactory()
    
    private var size: CGFloat = 40.0
    private var color = UIColor.whiteColor()
    
    private var animating = false
    
//    override init(frame: CGRect) {
//        
//        super.init(frame: frame)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    func startAnimating() {
        if layer.sublayers == nil {
            animation.configureAnimation(inlayer: layer, withSize: size)
        }
        layer.speed = 1.0
        animating = true
    }
    
    func stopAnimating() {
        layer.speed = 0.0
        animating = false
    }
    
}
