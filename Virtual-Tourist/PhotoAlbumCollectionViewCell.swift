//
//  PhotoAlbumCollectionViewCell.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/22/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import Spring

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var isUpdating = false
<<<<<<< HEAD
=======
    let stockPhoto = UIImage(named: "image-missing")
>>>>>>> newFeat
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /* If updating, don't allow selection */
    func isSelected(selected: Bool) {
        if isUpdating {
            return
        }
        
        /* If selected, fade out */
        if selected {
            self.fadeOut()
        } else {
            self.fadeIn()
        }
    }
    
    /* Handle the cell's updating state here */
    func setUpdatingState(updatingState: Bool){
        if updatingState == true {
            isUpdating = true
            imageView.image = stockPhoto
            imageView.fadeOut(0.2, delay: 0.0, endAlpha: 0.5, completion: nil)
        } else {
            isUpdating = false
            imageView.fadeIn(0.2, delay: 0.0, alpha: 1.0, completion: nil)
        }
    }
    
}