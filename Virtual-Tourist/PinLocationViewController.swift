//
//  PinLocationViewController.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/20/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import MapKit
import CoreData

protocol PinLocationPickerViewControllerDelegate {
    func pinLocation(pinPicker: PinLocationViewController, didPickPin pin: Pin?)
}

class PinLocationViewController: UIViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    
    var currentPin: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.delegate = self
        mapView.userInteractionEnabled = true
        
        restoreMapRegionState(false)
        
        /* Add long press gesture recognizer for adding pins */
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.addTarget(self, action: "addAnnotation:")
    }
    
    func addAnnotation(sender: UIGestureRecognizer) {

        let point = sender.locationInView(mapView)
        
        let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
        
        let pin = Pin(location: coordinate, context: sharedContext)
        
        switch sender.state {
        case .Began :
            print("Began adding pin")
            pin.setNewCoordinate(coordinate)
            self.currentPin = pin
            mapView.addAnnotation(pin)
            
        case .Changed :
            print("Changed Pin location")
            pin.setNewCoordinate(coordinate)
        case .Ended :
            print("Ended moving pin")
            pin.setNewCoordinate(coordinate)
            // prefetch images here
            
            CoreDataStackManager.sharedInstance().saveContext()
        default :
            return
        }
        
    }
    
    func fetchPhotos(forPin pin: Pin) {
        FlickrClient.sharedInstance().fetchPhotos(withLatitude: pin.latitude, longitude: pin.longitude, completionHandler: {success,results, error in
            if error != nil {
                print(error)
            } else {
                print(results)
            }
        })
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert :
            mapView.addAnnotation(anObject as! Pin)
        case .Update :
            mapView.removeAnnotation(anObject as! Pin)
        case .Delete :
            mapView.removeAnnotation(anObject as! Pin)
            mapView.addAnnotation(anObject as! Pin)
        default :
            break
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetch = NSFetchRequest(entityName: "Pin")
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        
        
        return fetchResultsController
    }()
    
    @IBAction func didTapCrosshairUpInside(sender: AnyObject) {
        let location = mapView.userLocation.coordinate
        centerMapOnLocation(location)
    }
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegion").path!
    }
    
    func saveMapState() {
        
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
        
    }
    
    func restoreMapRegionState(animated: Bool) {
        
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude =  regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let latitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let longitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            mapView.setRegion(savedRegion, animated: animated)
        }
        
        
    }
    
    /* Add an annotation for any saved location */
    func annotationsForSavedLocations() {
        
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    /* Center on current location */
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius * 4.0, regionRadius * 4.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    
    /* Find current location and zoom in */
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let center = CLLocationCoordinate2D(latitude: (userLocation.location?.coordinate.latitude)!, longitude: (userLocation.location?.coordinate.longitude)!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01))
        mapView.setRegion(region, animated: true)
    }


}

extension PinLocationViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapState()
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        print("Added a new location")
        

        
    }
    
    /* create a mapView indicator */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pin = "pin"
        
        var pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pin)
        if pinAnnotationView  == nil {
            pinAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: pin)
  
        } else {
            
            pinAnnotationView?.annotation = annotation
            
        }
        
        return pinAnnotationView
        
    }
}
