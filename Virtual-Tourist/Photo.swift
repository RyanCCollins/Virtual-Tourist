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
    @NSManaged var filePath : String?
    @NSManaged var fileURL : String?
    
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
        id = dictionary[FlickrClient.JSONResponseKeys.ID] as! Int
        self.pin = pin
        filePath = dictionary[FlickrClient.JSONResponseKeys.ImageSizes.MediumURL]?.lastPathComponent
        fileURL = dictionary[FlickrClient.JSONResponseKeys.ImageSizes.MediumURL] as? String
    }
    
    
    var image: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(filePath!)
        }
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: filePath!)
        }
    }
    
//    func getImage(fromFilePath filepath: String?) -> UIImage? {
//        return FlickrClient.Caches.imageCache.imageWithIdentifier(filepath)!
//    }
//    
//    func setImage(fromFilePath filepath: String?) -> UIImage? {
//        FlickrClient.Caches.imageCache.storeImage(UIImage(, withIdentifier: filePath!)
//    }
    
}

extension String {
    var fileName: String {
        get {
            return (self as NSString).lastPathComponent
        }
    }
}