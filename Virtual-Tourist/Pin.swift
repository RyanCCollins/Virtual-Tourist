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
        var error: NSError?
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
    
    /* Custom init for our NSManagedObject */
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
            return CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
        }
        set(newValue) {
            /* Note, setting the coordinate here here will help us to drag the pin */
            latitude = newValue.latitude
            longitude = newValue.longitude
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
    
    func configureLoadingStatus(loading: Bool, noPhotos: Bool, error: NSError?) {
        loadingStatus.isLoading = loading
        loadingStatus.noPhotosFound = noPhotos
        loadingStatus.error = error
    }
    
    /* Convenience method for fetching images from pin's photos, using NSNotifications to avoid messy callbacks */
    func fetchAndStoreImages(callback: CallbackHandler) {
        
        /* Set the loading status to a clean state to show loading */
        configureLoadingStatus(true, noPhotos: false, error: nil)
        
        var counter = 0
        
            FlickrClient.sharedInstance().taskForFetchPhotos(forPin: self, completionHandler: {success, photos, error in
                
             if error != nil {
                /* Call our callback with success false */
                
                self.configureLoadingStatus(false, noPhotos: false, error: error)
                callback(success: false, error: error)

             } else {
                
                if photos == nil || photos!.count == 0 {

                    self.configureLoadingStatus(false, noPhotos: true, error: nil)
                    callback(success: true, error: nil)
                    
                } else {
                
                    self.sharedContext.performBlockAndWait({
                        for photo in photos! {
                            photo.imageForPhoto({success, error in
                                
                                if success == true {
                                    
                                    counter++
                                    
                                } else if error != nil {
                                    
                                    self.configureLoadingStatus(false, noPhotos: false, error: error)
                                    callback(success: false, error: error)
                                    
                                }
                                /* Call success only when our loop finishes */
                                if counter == photos?.count {
                                    self.configureLoadingStatus(false, noPhotos: false, error: nil)
                                    callback(success: true, error: nil)
                                }
                                
                            })
                        }
                    })

                }

            }
        
        })
  
    }
    
}
