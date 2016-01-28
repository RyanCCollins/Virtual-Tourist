//
//  ExtendsUIViewController.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/21/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//
import UIKit
import Spring

extension UIViewController {

    /* Helper - Create an alert controller with an array of callback handlers   */
    func alertController(withTitles titles: [String], message: String, callbackHandler: [((UIAlertAction)->Void)?]) {
        
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .ActionSheet)
        
        for title in titles.enumerate() {
            
            if let callbackHandler = callbackHandler[title.index] {
                
                let action = UIAlertAction(title: title.element, style: .Default, handler: callbackHandler)
                
                alertController.addAction(action)
                
            } else {
                
                let action = UIAlertAction(title: title.element, style: .Default, handler: nil)
                
                alertController.addAction(action)
                
            }

        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }

}

extension UIView {
    func fadeIn(duration: NSTimeInterval = 0.1, delay: NSTimeInterval = 0.0, alpha: CGFloat = 1.0, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseIn, animations: {
            self.alpha = alpha
            }, completion: completion)
    }
    
    func fadeOut(duration: NSTimeInterval = 0.1, delay: NSTimeInterval = 0.0, endAlpha alpha: CGFloat = 0.2, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseIn, animations: {
            self.alpha = alpha
            }, completion: completion)
    }
    
    func transformIn(sender: AnyObject, transformationScale scale: (CGFloat, CGFloat) = (0.935, 0.935)) {
        SpringAnimation.spring(0.7, animations: {
            self.transform = CGAffineTransformMakeScale(1, 1)
        })
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    func transformOut(sender: AnyObject, transformationScale scale: (CGFloat, CGFloat) = (0.935, 0.935)) {
        SpringAnimation.spring(0.7, animations: {
            self.transform = CGAffineTransformMakeScale(scale)
        })
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
}