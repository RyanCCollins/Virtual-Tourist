//
//  TransitionDelegate.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 2/2/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit


/* This is the delegate for opening our collection view cell.
 * Note: I followed a tutorial in order to learn how to do this: http://zappdesigntemplates.com/uiviewcontroller-transition-from-uicollectionviewcell/
 */

class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var openingFrame: CGRect?
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentationAnimator = PhotoPresentationAnimator()
        presentationAnimator.openingFrame = openingFrame!
        return presentationAnimator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let tapToDismissAnimator = DismissalAnimator()
        tapToDismissAnimator.openingFrame = openingFrame!
        return tapToDismissAnimator
    }
}
