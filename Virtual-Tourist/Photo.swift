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
    @NSManaged var fullImageURL : String?
    @NSManaged var thumbnailURL : String?
    var thumbnailStatus = Status()
    var fullImageStatus = Status()
    
    struct Status {
        var isLoading: Bool = false
        var loaded: Bool = false
        var error: NSError?
    }
    
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
        
        thumbnailURL = dictionary[FlickrClient.JSONResponseKeys.ImageSizes.MediumURL] as? String
        fullImageURL = dictionary[FlickrClient.JSONResponseKeys.ImageSizes.LargeURL] as? String
        titleString = dictionary[FlickrClient.JSONResponseKeys.Title] as! String
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var imageThumb: UIImage? {
        get {
            return PhotoDatabase.Cache.imageWithIdentifier(thumbnailURL?.fileName)
        }
        set {
            PhotoDatabase.Cache.storeImage(newValue, withIdentifier: (thumbnailURL?.fileName)!)
        }
    }
    
    var imageFull: UIImage? {
        get {
            return PhotoDatabase.Cache.imageWithIdentifier(fullImageURL?.fileName)
        }
        set {
            PhotoDatabase.Cache.imageWithIdentifier(fullImageURL?.fileName)
        }
    }
    
    
    func loadThumbnails(callbackHandler: (success: Bool, error: NSError?)-> Void) {
        
        self.thumbnailStatus.isLoading = true
        
        FlickrClient.sharedInstance().taskForGETImageFromURL(self.thumbnailURL!, withSize: nil, completionHandler: {data, error in
            
            if error != nil {
                
                self.thumbnailStatus.error = error
                self.thumbnailStatus.isLoading = false
                callbackHandler(success: false, error: error)
            } else {
                
                self.imageThumb = UIImage(data: data as! NSData)
                CoreDataStackManager.sharedInstance().saveContext()
                callbackHandler(success: true, error: nil)
            }
        })
    }
    
    func deletePhoto() {
        self.sharedContext.performBlockAndWait({
            self.sharedContext.deleteObject(self)
            
            CoreDataStackManager.sharedInstance().saveContext()
        })
    }
    
    func loadFullImages(callbackHandler: (success: Bool, error: NSError?)-> Void) {
        FlickrClient.sharedInstance().taskForGETImageFromURL(self.fullImageURL!, withSize: nil, completionHandler: {data, error in
            
            if error != nil {
                
                self.fullImageStatus.isLoading = false
                callbackHandler(success: false, error: error)
                
            } else {
                
                self.imageFull = UIImage(data: data as! NSData)
                self.fullImageStatus.isLoading = false
                self.fullImageStatus.loaded = true
                callbackHandler(success: true, error: nil)
            }
            
        })
    }
}



extension String {
    var fileName: String {
        get {
            return (self as NSString).lastPathComponent
        }
    }
}