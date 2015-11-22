//
//  Photo.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/20/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    /* Define dictionary keys */

    
    /* Create our managed variables */
    @NSManaged var id: NSNumber
    @NSManaged var titleString: String
    @NSManaged var pin : Pin
    @NSManaged var largeImageFilePath : String?
    @NSManaged var thumbnailImageFilePath : String?
    @NSManaged var mediumImageFilePath : String?
    
    var images : [String : UIImage]? {
        
        if let thumbnail = thumbnailImageFilePath, large = largeImageFilePath, medium = mediumImageFilePath {
            
            let thumbnailFile = fileNameByDeletingPathExtension(fromString: thumbnailImageFilePath!)
            
            let mediumFile = fileNameByDeletingPathExtension(fromString: mediumImageFilePath)
            
        }
        
    }
    
    /* Include standard Core Data init method */
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /* Custom init */
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        
        /* Super, get to work! */
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        /* Assign our properties */
        id = dictionary[FlickrClient.JSONResponseKeys.ID] as! Int
        thumbnailImageFilePath = dictionary[FlickrClient.JSONResponseKeys.Extras.ThumbnailURL] as? String
        titleString = dictionary[FlickrClient.JSONResponseKeys.Title] as! String
        mediumImageFilePath = dictionary[FlickrClient.JSONResponseKeys.Extras.MediumURL] as? String
        largeImageFilePath = dictionary[FlickrClient.JSONResponseKeys.Extras.LargeURL] as? String
    }
    
    func getImage(fromFilePath filepath: String?) -> UIImage? {
        if filepath == nil || filepath == "" {
            return 
        }
        return FlickrClient.Caches.imageCache.imageWithIdentifier(filepath)!
    }
    
    var largeImage: UIImage? {
        get {
            
            return FlickrClient.Caches.imageCache.imageWithIdentifier(largeImageFilePath!)
        }
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath!)
        }
    }
    
}
