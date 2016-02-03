//
//  DismissDelegate.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 2/2/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

/*
* NOTE: I originally created this following the tutorial located here: http://zappdesigntemplates.com/uiviewcontroller-transition-from-uicollectionviewcell/
* I do not claim that I created the transitions, but I customized it and did a lot of research in order to implement a custom transition.
*/

class DismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    /* The opening frame shows the view zooming out */
    var openingFrame: CGRect?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    /* Define the transition elements, from, to, container, etc. for dismissing the animation */
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        
        let animationDuration = self .transitionDuration(transitionContext)
        
        let snapshotView = fromViewController.view.resizableSnapshotViewFromRect(fromViewController.view.bounds, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsZero)
        containerView!.addSubview(snapshotView)
        
        fromViewController.view.alpha = 0.0
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            /* Set the snapshotview for showing transition */
            snapshotView.frame = self.openingFrame!
            snapshotView.alpha = 0.0
            }) {finished in
                snapshotView.removeFromSuperview()
                fromViewController.view.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}
