//
//  Settings.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 1/8/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData

class Settings: NSManagedObject {
    @NSManaged var funMode: Bool
    @NSManaged var saveAlbums: Bool
    @NSManaged var numPhotos: NSNumber?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    struct Keys {
        static let funMode = "funMode"
        static let saveAlbums = "saveAlbums"
        static let numPhotos = "numberOfPhotos"
    }
    
    /* Custom init */
    init(dictionary: [String: AnyObject?], context: NSManagedObjectContext) {
        
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("Settings", inManagedObjectContext: context)!
        
        /* Super, get to work! */
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        /* Assign our properties */
        funMode = dictionary[Keys.funMode] as! Bool
        saveAlbums = dictionary[Keys.saveAlbums] as! Bool
        
        if let numberPhotos = dictionary[Keys.numPhotos] as? NSNumber {
            numPhotos = numberPhotos
        } else {
            numPhotos = 24
        }

    }
}