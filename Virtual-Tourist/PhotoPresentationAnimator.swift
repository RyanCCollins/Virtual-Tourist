//
//  PhotoAnimator.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 2/2/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//


/* This class is responsible for presenting the photo when a collection view is tapped */

import UIKit

class PhotoPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var openingFrame: CGRect?
    
    /* Set the duration of the animation */
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    /* Define the animation transition */
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! FullImageViewController
        let containerView = transitionContext.containerView()
        
        let animationDuration = self .transitionDuration(transitionContext)
        
        /* Add blurred background to the view */
        let fromViewFrame = fromViewController.view.frame
        
        UIGraphicsBeginImageContext(fromViewFrame.size)
        fromViewController.view.drawViewHierarchyInRect(fromViewFrame, afterScreenUpdates: true)
        
        /* Note, we can use the snapshot image to provide a better image for the transition, although we are not currently using due to performance issues */
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshotView = toViewController.view.resizableSnapshotViewFromRect(toViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsZero)
        snapshotView.frame = openingFrame!
        containerView!.addSubview(snapshotView)
        
        /* Dim the alpha of the background views */
        toViewController.dimView.alpha = 0.0
        toViewController.view.alpha = 0.0
        
        containerView!.addSubview(toViewController.view)
        
        /* Set the animation properties for the transition */
        UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10.0, options: [],
            animations: { Void in
                /* Create a snapshot view that animates to show the view expanding */
                snapshotView.frame = fromViewController.view.frame
            
            /* Handle the presentation completion */
            }, completion: {finished in
                snapshotView.removeFromSuperview()

                toViewController.imageView.alpha = 1.0
                toViewController.dimView.alpha = 0.8
                toViewController.view.alpha = 1.0
                
                transitionContext.completeTransition(finished)
        })
    }
}
