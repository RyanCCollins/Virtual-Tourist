//
//  Photo.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/20/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)

class Photo: NSManagedObject {
    /* Define dictionary keys */

    
    /* Create our managed variables */
    @NSManaged var titleString: String
    @NSManaged var pin : Pin
    @NSManaged var filePath : String?
    @NSManaged var url_t : String?
    @NSManaged var url_m: String?
    
    struct Status {
        var isLoading = false
    }
    
    var loadingStatus = Status()
    
    /* Include standard Core Data init method */
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /* Custom init */
    init(dictionary: [String : AnyObject], pin: Pin, context: NSManagedObjectContext) {
        
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        
        /* Super, get to work! */
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        /* Assign our properties */
        self.pin = pin
        filePath = dictionary[FlickrClient.JSONResponseKeys.ImageSizes.MediumURL]?.lastPathComponent
        url_t = dictionary[FlickrClient.JSONResponseKeys.ImageSizes.ThumbnailURL] as? String
        titleString = dictionary[FlickrClient.JSONResponseKeys.Title] as! String
        url_m = dictionary[FlickrClient.JSONResponseKeys.ImageSizes.MediumURL] as? String
    }
    
    var imageFull: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(filePath!)
        }
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: filePath!)
        }
    }
    
    var imageThumb: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(filePath?.thumbnailName)
        }
        set {
            FlickrClient.Caches.imageCache.imageWithIdentifier(filePath?.thumbnailName)
        }
    }
}

/* Helps to bridge string & NSString functions for getting filepath & filename for different files: */
extension String {
    var path: String {
        get {
            return ns.lastPathComponent
        }
    }
    var name: String {
        get {
            return ns.stringByDeletingPathExtension
        }
    }
    var thumbnailName: String {
        get {
            let returnVal = name + "_t." + ns.pathExtension
            return returnVal
        }
    }
    var ns: NSString {
        return self as NSString
    }
    
}
