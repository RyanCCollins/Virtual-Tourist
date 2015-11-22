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


class Pin: NSManagedObject, MKAnnotation {
    
    /* Define dictionary keys */
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let UpdatedAt = "updatedAt"
        static let Photos = "photos"
    }
    
    /* Create our managed variables */
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var geoDescriptor: String
    @NSManaged var photos: [Photo]
    @NSManaged var updatedAt: NSDate
    @NSManaged var countOfPhotoPages: NSNumber?
    
    /* Include standard Core Data init method */
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /* Custom init */
    init(location: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)
        
        /* Super, get to work! */
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        /* Assign our properties */
        latitude = NSNumber(double: location.latitude)
        longitude = NSNumber(double: location.longitude)
        updatedAt = computedDate()
        geoDescriptor = computedGEODescriptor()
        photos = [Photo]()
    }
    
    
    /* Convenience: Get and set a CLLocationCoordinate2D */
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(Double(latitude), Double(longitude))
        }
        set {
            self.latitude = coordinate.latitude
            self.longitude = coordinate.longitude
        }
    }
    
    func setNewCoordinate(newCoordinate: CLLocationCoordinate2D) {
        willChangeValueForKey("coordinate")
        
        self.updatedAt = computedDate()
        self.coordinate = newCoordinate
        didChangeValueForKey("coordinate")
        
        self.geoDescriptor = computedGEODescriptor()
        
        didChangeValueForKey("coordinate")

        
    }
    
    func computedGEODescriptor()-> String {
        
        let geocodeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        var geocodeString = "Unkown Place"
        
        CLGeocoder().reverseGeocodeLocation(geocodeLocation, completionHandler: {(placemarks, error) in
            
            if placemarks?.count > 0 {
                let placemark = placemarks![0]
                
                if placemark.thoroughfare != nil && placemark.subThoroughfare != nil {
                
                    geocodeString = placemark.thoroughfare! + ", " + placemark.subThoroughfare!

                }
            }
        })
        return geocodeString
    }
    
    func computedDate()-> NSDate {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Month, .Day, .Year, .Hour, .Minute, .Second, .TimeZone], fromDate: date)
        return calendar.dateFromComponents(components)!
    }
    
}
