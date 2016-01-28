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
<<<<<<< HEAD
    var needsNewPhotosFromFlickr: Bool = true
    typealias CompletionHandler = (success: Bool, error: NSError?) -> Void
=======
    var loadingError: NSError?
    var coordinateDelta: Double?
    var status: Status? = nil
>>>>>>> newFeat
    
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
<<<<<<< HEAD
=======
            let oldLocation = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
            let newLocation = CLLocation(latitude: newValue.latitude, longitude: newValue.longitude)
            
            /* Gives the delta from the last coordinate In Kilometers when a new location is set */
            coordinateDelta = newLocation.distanceFromLocation(oldLocation) / 1000
>>>>>>> newFeat
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
    
    func getNewPhotos(completionHandler: CompletionHandler) {
        paginate()
        
        if needsNewPhotosFromFlickr {
            
            FlickrClient.sharedInstance().taskForFetchPhotos(forPin: self, completionHandler: {success, photos, error in
                
                if error != nil {
                    /* Todo: Report error */
                    completionHandler(success: false, error: error)
                } else {
                    self.photos = photos
                    print(photos)
                    CoreDataStackManager.sharedInstance().saveContext()
                    
                }

                
            })
        }
        
        for photo in self.photos! {
            photo.loadThumbnails({success, error in
                if error != nil {
                    completionHandler(success: false, error: error)
                }
                
            })
        }
        completionHandler(success: true, error: nil)
    }
    
<<<<<<< HEAD
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
=======
    /* Returns false only when the delta between coordinate changes is less than or equal to 2 KM */
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
        status?.isLoading = true
        
        loadingError = nil
        
        /* If new photos are needed, fetch them first */
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.willFinishLoadingThumbnails, object: self)
        
        if needsNewPhotos {
            FlickrClient.sharedInstance().taskForFetchPhotos(forPin: self, completionHandler: {success, error in
                
                 if error != nil {
                    /* defer error to other view by setting an error for the pin here */
                    self.loadingError = error
                    
                }
                
            })
        }
        
        if photos != nil {
            for photo in photos! {
                photo.imageForPhoto({success, error in
                    if error != nil {
                        self.loadingError = error
                    }
                })
                }
            }

        /* Need to handle the loading error if one occurs, otherwise this will post that this execution did finish. */
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.didFinishLoadingThumbails, object: self)
        status?.isLoading = false
        
        if let completionHandler = completionHandler {
        if loadingError != nil {
            completionHandler(success: false, error: loadingError)
        } else {
            completionHandler(success: true, error: nil)
        }
>>>>>>> newFeat
        }
        completionHandler()
    }
    
    /* Core data */
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    /* Helps deal with our NSNumber to Int bridging */
//    func incrementCurrentPage()-> Void {
//        if self.currentPage != nil {
//            var currentPage = self.currentPage as! Int, count = self.countOfPhotoPages as! Int
//            if currentPage < count {
//                currentPage++
//                self.currentPage = currentPage
//                needsNewPhotos = false
//                return
//            }
//        }
//        self.currentPage = 1
//        needsNewPhotos = true
//    }
    
}
