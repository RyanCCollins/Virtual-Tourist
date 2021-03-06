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
    @NSManaged var fullImageURL : String?
    @NSManaged var thumbnailURL : String?

    
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
            guard filePath != nil else {
                return nil
            }
            
            return FlickrClient.Caches.imageCache.imageWithIdentifier(filePath!)
        }
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: filePath!)
        }
    }
    
    /* Delete associated backing image files automatically. */
    override func prepareForDeletion() {

        let fileName = filePath!.lastPathComponent
            
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let pathArray = [dirPath, fileName]
        let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
        
        do {
            try NSFileManager.defaultManager().removeItemAtURL(fileURL)
        } catch _ {
        }
    }

    /* Convenience for loading the image for the photo */
    func imageForPhoto(completionHandler: CallbackHandler?) {

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


/* Added to help bridge the gap for finding the last path component in Swift
Reference are here: https://forums.developer.apple.com/thread/13580 */

extension String {
    
    var lastPathComponent: String {
        
        get {
            return (self as NSString).lastPathComponent
        }
    }
}