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
    func pinLocation(pinPicker: PinLocationViewController, didPickPin pin: Pin)
}

class PinLocationViewController: UIViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    
    var pinToAdd: Pin? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.delegate = self
        mapView.userInteractionEnabled = true
        
        restoreMapRegionState(false)
        
        /* Add long press gesture recognizer for adding pins */
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.addTarget(self, action: "addAnnotation:")
        configureAnnotations()
        
    }
    
    func addAnnotation(sender: UIGestureRecognizer) {

        let point: CGPoint = sender.locationInView(mapView)
        print(point)
        let coordinate: CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)
        print(coordinate)
        switch sender.state {
        case .Began :

            pinToAdd = Pin(coordinate: coordinate, context: sharedContext)
            mapView.addAnnotation(pinToAdd!)
        case .Changed :
            pinToAdd!.willChangeValueForKey("coordinate")
            pinToAdd!.coordinate = coordinate
            pinToAdd!.didChangeValueForKey("coordinate")
        case .Ended :

            fetchPhotos(forPin: pinToAdd!)
            CoreDataStackManager.sharedInstance().saveContext()
        default :
            return
        }
        
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
    
    lazy var scratchContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext()
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        return context
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetch = NSFetchRequest(entityName: "Pin")
        
        fetch.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        

        do {
            try fetchResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        return fetchResultsController
    }()
    
    func configureAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(fetchedResultsController.fetchedObjects as! [Pin])
        
    }
    
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
    
    func fetchPhotos(forPin pin: Pin) {
//        if pin.photos == nil {
        FlickrClient.sharedInstance().taskForFetchPhotos(forPin: pin, completionHandler: {success, error in
            
            if success {

                CoreDataStackManager.sharedInstance().saveContext()
                
            } else {
                
                self.alertController(withTitles: ["Ok", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, {Void in
                    self.fetchPhotos(forPin: pin)
                }])
                
            }
            
        })
//        }
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

/* Map view extension methods */
extension PinLocationViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapState()
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let galleryViewController = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        
        let pin = view.annotation as! Pin
        
        galleryViewController.pinLocation(self, didPickPin: pin)
        
        navigationController?.pushViewController(galleryViewController, animated: true)
        
    }
    
    /* create a mapView indicator */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? Pin {
            
            let pinId = "pin"
            
            var annotationViewToReturn: MKPinAnnotationView
            
            /* If we are reusing the annotation view, set a new annotation */
            if let pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pinId) as? MKPinAnnotationView {
                
                pinAnnotationView.annotation = annotation
                annotationViewToReturn = pinAnnotationView
                
            } else {
                /* If new annotation view, configure and return */
                annotationViewToReturn = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
                annotationViewToReturn.animatesDrop = true
                annotationViewToReturn.draggable = true
                annotationViewToReturn.canShowCallout = false
            }
            return annotationViewToReturn
        }
        return nil
    }
    
}
