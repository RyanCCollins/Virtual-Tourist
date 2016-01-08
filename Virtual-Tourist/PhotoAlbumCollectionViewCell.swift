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
    var isUpdating = false
    
    let selectedColor = UIColor.grayColor()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func isSelected(selected: Bool) {
            if selected {
                self.fadeOut()
            } else {
                self.fadeIn()
            }
    }
    

}