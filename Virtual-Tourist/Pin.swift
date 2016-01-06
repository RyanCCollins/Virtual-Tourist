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
    @NSManaged var currentPage: NSNumber?
    var needsNewPhotosFromFlickr: Bool = true
    dynamic var countOfLoadedPhotos = 0
    
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
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
            self.needsNewPhotosFromFlickr = true
        }
    }
        
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    /* Handles all logic for fetching photos for a pin, abstracting it away from view controllers,
     * Make sure to proceed with completion handler within view controllers for error management.
     */
    
    func getNewPhotos(completionHandler: (success: Bool, error: NSError?)-> Void) {
        paginate()
        
        if needsNewPhotosFromFlickr {
            FlickrClient.sharedInstance().taskForFetchPhotoURLs(forPin: self, completionHandler: {success, results, error in
                
                if error != nil {
                    /* Todo: Report error */
                    completionHandler(success: false, error: error)
                } else {
                    
                    self.fetchThumbnails()
                    
                }

                
            })
        } else {
            
            fetchThumbnails()
            
        }
    }
    
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
    
    func fetchThumbnails(completionHandler:) {
            
        if self.photos != nil {
            for photo in self.photos! {
                print("Got a photo: \(photo)")
                
                photo.loadThumbnails({success, error in
                    if error != nil {
                        print(error)
                    } else {
                        self.countOfLoadedPhotos++
                        print("Successfully got thumbnail URLS")
                    }
                })
                
            }
        } else {
            
            self.getNewPhotos()
            
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
        completionHandler()
    }
    
}
