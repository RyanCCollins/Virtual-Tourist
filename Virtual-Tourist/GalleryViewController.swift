//
//  GalleryViewController.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/20/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

class GalleryViewController: UIViewController {
    var selectedPhoto: Photo?
    var image: UIImage?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        image = selectedPhoto?.imageFull
        if image == nil {
            selectedPhoto.
        }
    }
}