//
//  Annotation.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/21/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation {
    private var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private var point: MKPointAnnotation = MKPointAnnotation()
    dynamic var GEODescriptor: String = ""
    dynamic var updateDate = NSDate()
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return location
        }
    }
    
    func setUpdateDate() {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Month, .Day, .Year, .Hour, .Minute, .Second, .TimeZone], fromDate: date)
        self.updateDate = calendar.dateFromComponents(components)!
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        willChangeValueForKey("coordinate")
        
        setUpdateDate()
        self.location = newCoordinate
        setGEODescriptorValue({Void in
            self.didChangeValueForKey("coordinate")
        })
        
    }
    
    var taskToCancelIfNewPinPicked: NSURLSessionTask? {
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
    func setGEODescriptorValue(completionHandler: ()-> Void) {
        let geocodeLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        CLGeocoder().reverseGeocodeLocation(geocodeLocation, completionHandler: {(placemarks, error) in

            if placemarks?.count > 0 {
                let placemark = placemarks![0]
                if placemark.thoroughfare != nil && placemark.subThoroughfare != nil {
                    self.GEODescriptor = placemark.thoroughfare! + ", " + placemark.subThoroughfare!
                    completionHandler()
                }
            }
                
            self.GEODescriptor = "Unknown Place"
            completionHandler()
        })
    }
    
}
