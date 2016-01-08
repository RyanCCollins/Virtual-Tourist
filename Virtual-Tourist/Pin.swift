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
    var needsNewPhotos: Bool = true
    var loadingError: NSError?
    
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
        }
    }
    
    /* Convenience method for fetching thumbnails from pin's photos, using NSNotifications to avoid messy callbacks */
    func fetchThumbnails(completionHandler: CallbackHandler?) {
        loadingError = nil
        
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.willFinishLoadingThumbnails, object: self)
        if photos != nil {
            for photo in photos! {
                FlickrClient.sharedInstance().taskForGETImageFromURL(photo.url_m!, completionHandler: {success, error in
                    
                })
            }
        }
        /* Need to handle the loading error if one occurs, otherwise this will post that this execution did finish. */
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.didFinishLoadingThumbails, object: self)
        
        if let completionHandler = completionHandler {
        if loadingError != nil {
            completionHandler(success: false, error: loadingError)
        } else {
            completionHandler(success: true, error: nil)
        }
        }
    }
    
    /* Helps deal with our NSNumber to Int bridging */
    func incrementCurrentPage()-> Void {
        if self.currentPage != nil {
            var currentPage = self.currentPage as! Int, count = self.countOfPhotoPages as! Int
            if currentPage < count {
                currentPage++
                self.currentPage = currentPage
                needsNewPhotos = false
                return
            }
        }
        self.currentPage = 1
        needsNewPhotos = true
    }
    
}
