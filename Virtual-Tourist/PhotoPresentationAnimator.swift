//
//  PhotoAnimator.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 2/2/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//


import UIKit

class PhotoPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var openingFrame: CGRect?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! FullImageViewController
        let containerView = transitionContext.containerView()
        
        let animationDuration = self .transitionDuration(transitionContext)
        
        // add blurred background to the view
        let fromViewFrame = fromViewController.view.frame
        
        UIGraphicsBeginImageContext(fromViewFrame.size)
        fromViewController.view.drawViewHierarchyInRect(fromViewFrame, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshotView = toViewController.view.resizableSnapshotViewFromRect(toViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsZero)
        snapshotView.frame = openingFrame!
        containerView!.addSubview(snapshotView)
        
        
        toViewController.dimView.alpha = 0.0
        
        containerView!.addSubview(toViewController.view)
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10.0, options: [],
            animations: { Void in
                
                snapshotView.frame = fromViewController.view.frame
            
            }, completion: {finished in
                snapshotView.removeFromSuperview()

                toViewController.imageView.alpha = 1.0
                toViewController.dimView.alpha = 0.8
                toViewController.view.alpha = 1.0
                
                transitionContext.completeTransition(finished)
        })
    }
}
