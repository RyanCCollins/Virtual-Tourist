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
        titleString = dictionary[FlickrClient.JSONResponseKeys.Title] as! String
        url_m = dictionary[FlickrClient.JSONResponseKeys.ImageSizes.MediumURL] as? String
    }
    
    var image: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(filePath!)
        }
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: filePath!)
        }
    }

    
    func imageForPhoto(completionHandler: CallbackHandler?) {
        loadingStatus.isLoading = true
        FlickrClient.sharedInstance().taskForGETImageFromURL(self.url_m!, completionHandler: {image, error in
            if image == nil || error != nil {
                if let callback = completionHandler {
                    callback(success: false, error: error)
                }
            } else {
                self.image = image
                if let callback = completionHandler {
                    callback(success: true, error: nil)
                }
            }
        })
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
