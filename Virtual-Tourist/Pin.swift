//
//  Pin.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/20/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class Pin: NSManagedObject {
    
    /* Define dictionary keys */
    struct Keys {
        static let ID = "id"
        static let GEODescriptor = "geoDescriptor"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let UpdatedAt = "updatedAt"
        static let Photos = "photos"
    }
    
    /* Create our managed variables */
    @NSManaged var id: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var geoDescriptor: String
    @NSManaged var photos: [Photo]
    
    /* Include standard Core Data init method */
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /* Custom init */
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)
        
        /* Super, get to work! */
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        /* Assign our properties */
        id = dictionary[Keys.ID] as! Int
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double
        geoDescriptor = dictionary[Keys.GEODescriptor] as! String

    }
    
    /* Convenience init, takes a given annotation and creates a Pin object to be stored in core data */
    convenience init(annotation: Annotation, context: NSManagedObjectContext) {
        let dictionary: [String : AnyObject] = [
            Keys.ID : 0,
            Keys.Latitude : annotation.coordinate.longitude,
            Keys.Longitude : annotation.coordinate.latitude,
            Keys.GEODescriptor : annotation.GEODescriptor,
            Keys.UpdatedAt : annotation.updateDate
            
        ]
        self.init(dictionary: dictionary, context: context)
    }
    
}
