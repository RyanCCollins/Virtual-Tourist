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
    var photo: Photo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /* Conveniently set the selected state. If updating, don't allow selection */
    func setSelectedState() {
        if isUpdating == true {
            return
        }
        
        if selected == true {
            self.fadeOut()
        } else {
            self.fadeIn()
        }
    }

    /* Handle the cell's updating state here */
    func setUpdatingState(updatingState: Bool){
        if updatingState == true {
            isUpdating = true
            /* Almost instantaneously fade out */
            imageView.fadeOut(0.01, delay: 0.0, endAlpha: 0.5, completion: nil)
        } else {
            isUpdating = false
            imageView.fadeIn(0.5, delay: 0.0, alpha: 1.0, completion: nil)
        }
    }
    
}