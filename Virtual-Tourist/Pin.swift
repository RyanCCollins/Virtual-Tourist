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
    
    struct Status {
        var isLoading: Bool = false
    }
    
    /* Create our managed variables */
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: [Photo]?
    @NSManaged var countOfPhotoPages: NSNumber?
    @NSManaged var currentPage: NSNumber?
    var loadingError: NSError?
    var coordinateDelta: Double?
    var status = Status()
    var needsNewPhotosFromFlickr: Bool = true
    typealias CompletionHandler = (success: Bool, error: NSError?) -> Void
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
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
            let oldLocation = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
            let newLocation = CLLocation(latitude: newValue.latitude, longitude: newValue.longitude)
            
            /* Gives the delta from the last coordinate In Kilometers when a new location is set */
            coordinateDelta = newLocation.distanceFromLocation(oldLocation) / 1000
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
    }
    
    /* Page through the returned values, setting a new one each time we loop through */
    func paginate() {
        
        var total = countOfPhotoPages as! Int, current = currentPage as! Int
        
        if current < total {
        
            let nextPage = current++
            currentPage = nextPage as NSNumber
            needsNewPhotosFromFlickr = false
        
        } else {
            
            needsNewPhotosFromFlickr = true
            
        }
    }
    
    
    /* Deletes all associated photos */
    func deleteAllAssociatedPhotos(completionHandler: () -> Void) {
        if photos != nil {
            for photo in photos! {
                sharedContext.performBlockAndWait({
                    self.sharedContext.deleteObject(photo)
                })
            }
        }
    }
    
    /* Core data NSManagedObjectContext */
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    /* Returns false only when the delta between coordinate changes is less than or equal to 2 KM so that we don't get more photos if we don't have to */
    var needsNewPhotos: Bool {
        get {
            if let delta = coordinateDelta {
            if delta <= 2 {
                print("Coordinate Delta is: \(delta) returning false")
                return false
            }
            }
            return true
        }
        set {
            /* Reset the coordinate delta */
            coordinateDelta = 0
            return
        }
    }
    
    /* Convenience method for fetching images from pin's photos, using NSNotifications to avoid messy callbacks */
    func fetchAndStoreImages(completionHandler: CallbackHandler?) {
        status.isLoading = true
        
        loadingError = nil

        /* If new photos are needed, go and get them from flicker with the tastForFetchPhotos */
        if needsNewPhotos {
            FlickrClient.sharedInstance().taskForFetchPhotos(forPin: self, completionHandler: {success, photos, error in
                
                 if error != nil {
                    /* defer error to other view by setting an error for the pin here */
                    self.loadingError = error
                    print(error)
                    
                 } else {
                    if photos != nil {
                        for photo in photos! {
                            photo.imageForPhoto({success, error in
                                if error != nil {
                                    self.loadingError = error
                                } else {
                                    print("Success loading photos")
                                }
                            })
                        }
                    }
                }
            })
        } 

        status.isLoading = false
        
        /* If we've passed in a completionhandler, call it and return results*/
        if let completionHandler = completionHandler {
        if loadingError != nil {
            
            completionHandler(success: false, error: loadingError)
        
        } else {
        
            completionHandler(success: true, error: nil)
        
            }
        }
    }
    
}
