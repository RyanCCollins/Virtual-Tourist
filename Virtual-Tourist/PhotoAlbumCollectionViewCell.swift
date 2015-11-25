//
//  PhotoAlbumCollectionViewCell.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/22/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let stockPhoto = UIImage(named: "missing-resource")
    let selectedColor = UIColor.grayColor()
    var isUpdating = false
//    let gestureRecognizer = UIGestureRecognizer(target: view, action: "isSelected:")
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if imageView.image == nil {
            activityIndicator.startAnimating()
        }
    }
    
    func isReloading(reloading: Bool) {
        
        activityIndicator.hidden = !reloading
        if reloading {
            activityIndicator.startAnimating()
            imageView.alpha = 0.0
            imageView.image = nil
        } else {
            activityIndicator.stopAnimating()
            imageView.alpha = 1.0
        }
    }
    
    func isSelected(selected: Bool) {
        if selected {
            self.fadeOut()
        } else {
            self.fadeIn()
        }
    }
}