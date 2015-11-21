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
    struct Keys {
        static let ID = "id"
        static let ImagePath = "imagePath"
        static let Description = "descriptioString"
        static let Title = "titleString"
        static let User = "userString"
    }
    
    /* Create our managed variables */
    @NSManaged var id: NSNumber
    @NSManaged var imagePath: String
    @NSManaged var descriptionString: String
    @NSManaged var titleString: String
    @NSManaged var userString: String
    @NSManaged var pin : Pin
    
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
        id = dictionary[Keys.ID] as! Int
        imagePath = dictionary[Keys.ImagePath] as! String
        titleString = dictionary[Keys.Title] as! String
        descriptionString = dictionary[Keys.Description] as! String
        userString = dictionary[Keys.User] as! String
    }
}
