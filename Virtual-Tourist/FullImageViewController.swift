//
//  FullImageViewController.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 2/2/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//
/*
* NOTE: I originally created this following the tutorial located here: http://zappdesigntemplates.com/uiviewcontroller-transition-from-uicollectionviewcell/
* I do not claim that I created the transitions, but I customized it and did a lot of research in order to implement a custom transition.
*/


import UIKit
import QuartzCore

class FullImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    /* Give us a dimmed view that we can fade in during the transition */
    @IBOutlet weak var dimView: UIView!
    
    var photo: Photo!
    
    @IBOutlet weak var imageTitleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 1.0
        
        imageTitleLabel.text = photo.titleString
        imageView.image = photo.image!
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "viewTapped")
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func viewTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
