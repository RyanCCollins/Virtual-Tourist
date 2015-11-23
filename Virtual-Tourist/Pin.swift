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

@objc(Pin)

class Pin: NSManagedObject, MKAnnotation {
    
    /* Define dictionary keys */
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Photos = "photos"
    }
    
    /* Create our managed variables */
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: [Photo]?
    @NSManaged var countOfPhotoPages: NSNumber?
    
    /* Include standard Core Data init method */
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /* Custom init */
    init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        /* Super, get to work! */
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        /* Assign our properties */
        latitude = coordinate.latitude 
        longitude = coordinate.longitude
    }
    
    
    /* Convenience: Get and set a CLLocationCoordinate2D */
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(Double(latitude), Double(longitude))
        }
        set {
            print("Set coordinate")
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
    }
    
//    func setNewCoordinate(newCoordinate: CLLocationCoordinate2D) {
//        willChangeValueForKey("coordinate")
//        
//        self.coordinate = newCoordinate
//        
//        didChangeValueForKey("coordinate")
//
//        
//    }
    
//    func computedGEODescriptor()-> String {
//        
//        let geocodeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        
//        var geocodeString = "Unkown Place"
//        
//        CLGeocoder().reverseGeocodeLocation(geocodeLocation, completionHandler: {(placemarks, error) in
//            
//            if placemarks?.count > 0 {
//                let placemark = placemarks![0]
//                
//                if placemark.thoroughfare != nil && placemark.subThoroughfare != nil {
//                
//                    geocodeString = placemark.thoroughfare! + ", " + placemark.subThoroughfare!
//
//                }
//            }
//        })
//        return geocodeString
//    }
    
}
