//
//  Settings.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 1/8/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData

@objc(Settings)

class Settings: NSManagedObject {

    @NSManaged var funMode: NSNumber
    @NSManaged var timeStamp: NSDate
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    struct Keys {
        static let funMode = "funMode"
    }
    
    /* Automagically insert the current time stamp */
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        let date = NSDate()
        self.timeStamp = date
    }
    
    /* Custom init */
    init(dictionary: [String: AnyObject?], context: NSManagedObjectContext) {
        
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("Settings", inManagedObjectContext: context)!
        
        /* Super, get to work! */
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        /* Assign our properties */
        funMode = dictionary[Keys.funMode] as! NSNumber
    }
}


