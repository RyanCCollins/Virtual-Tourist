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
        var noPhotosFound: Bool = false
    }
    
    /* Create our managed variables */
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: [Photo]?
    @NSManaged var countOfPhotoPages: NSNumber?
    @NSManaged var currentPage: NSNumber?

    
    var loadingError: NSError?
    var coordinateDelta: Double?
    var loadingStatus = Status()
    
    typealias CompletionHandler = (success: Bool, error: NSError?) -> Void
    
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
    
    /* Page through the returned values, setting a new value in order to get the next page of photos if possible */
    func paginate() -> Bool {
        let current = currentPage as! Int

        if hasPhotosLeft() == true {
            let nextPage = current + 1
            currentPage = nextPage as NSNumber
            print(currentPage)
            return true
        } else {
            return false
        }
    }
    
    /* Figure out whether or not there are photos left to get from Flickr in order to paginate. */
    func hasPhotosLeft() -> Bool {
        let total = countOfPhotoPages as! Int, current = currentPage as! Int
        
        if current < total {
            print("Current page is: \(current)")
            print("Total pages is: \(total)")
            return true
        } else {
            return false
        }
    }
    
    /* Deletes all associated photos */
    func deleteAllAssociatedPhotos() {
        if photos != nil {
            for photo in photos! {
                sharedContext.deleteObject(photo)
            }
            
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    /* Core data NSManagedObjectContext */
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func loadedPhotoCount() -> Int {
        if photos != nil {
            return photos!.count
        } else {
            return 0
        }
    }
    
    /* Convenience method for fetching images from pin's photos, using NSNotifications to avoid messy callbacks */
    func fetchAndStoreImages(callback: CallbackHandler) {
        loadingStatus.isLoading = true
        
        var counter = 0
        
            FlickrClient.sharedInstance().taskForFetchPhotos(forPin: self, completionHandler: {success, photos, error in
                
             if error != nil {
                /* Call our callback with success false */
                callback(success: false, error: error)

             } else {
                
                if photos == nil || photos!.count == 0 {
                    print("Callback called")
                    self.loadingStatus.isLoading = false
                    self.loadingStatus.noPhotosFound = true
                    callback(success: true, error: nil)
                } else {
                    
                    for photo in photos! {
                        photo.imageForPhoto({success, error in
                            
                            if success == true {
                                
                                counter++
                            } else {
                                self.loadingStatus.isLoading = false
                                callback(success: false, error: error)
                                
                            }
                            /* Call success only when our loop finishes */
                            if counter == photos?.count {
                                self.loadingStatus.noPhotosFound = false
                                
                                self.loadingStatus.isLoading = false
                                callback(success: true, error: nil)
                            }
                            
                        })
                    }
                    
                }

            }
        
        })
  
    }
    
}
