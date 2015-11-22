//
//  ExtendsUIViewController.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/21/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//
import UIKit

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