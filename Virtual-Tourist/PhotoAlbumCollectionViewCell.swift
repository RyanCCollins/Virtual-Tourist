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
    let stockPhoto = UIImage(named: "missing-resource")
    let selectedColor = UIColor.grayColor()
    var isUpdating = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if imageView.image == nil {
            self.imageView.image = stockPhoto
        }
    }
    
    
    func isSelected(selected: Bool) {
        if !isUpdating {
            if selected {
                self.fadeOut()
            } else {
                self.fadeIn()
            }
        }
    }
    

}