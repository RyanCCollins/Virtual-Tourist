//
//  GalleryViewController.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/20/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

<<<<<<< HEAD
//import UIKit
//import CoreData
//
//class GalleryViewController: UIViewController {
//    let photo: Photo?
//    
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
//    
//    override func viewWillAppear(animated: Bool) {
//        let imageToShow = photo!.image
//        
//        if imageToShow == nil {
//            
//        } else {
//            imageView.image = imageToShow
//            
//        }
//        super.viewWillAppear(animated)
//    }
//    
//
//}
=======
import UIKit
import CoreData

class GalleryViewController: UIViewController {
    var selectedPhoto: Photo?
    var image: UIImage?
    
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        image = selectedPhoto?.image
        if image != nil {
            selectedPhoto!.image = image
        } else {
            
        }
    }
}
>>>>>>> newFeat
