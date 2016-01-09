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
import Spring

/* Protocol for passing pin to delegate */
protocol PinLocationPickerViewControllerDelegate {
    func pinLocation(pinPicker: PinLocationViewController, didPickPin pin: Pin)
}

class PinLocationViewController: UIViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var tapPinsToDeleteBanner: SpringLabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    /* Creating my own editing var because included is being changed randomly */
    var _editing: Bool = false
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let regionRadius: CLLocationDistance = 1000
    
    /* Pin to add defined globally, for use when rearranging pins */
    var pinToAdd: Pin? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Map view delegate methods */
        mapView.delegate = self
        mapView.userInteractionEnabled = true
        
        restoreMapRegionState(false)
        
        /* Add long press gesture recognizer for adding pins */
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.addTarget(self, action: "addAnnotation:")
        configureAllAnnotations()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Handle editing button here */
        _editing = false
        editButton.title = "Edit"
        tapPinsToDeleteBanner.hidden = true
    }
    
    func addAnnotation(sender: UIGestureRecognizer) {

        let point: CGPoint = sender.locationInView(mapView)

        let coordinate: CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)

        switch sender.state {
        case .Began :

            pinToAdd = Pin(coordinate: coordinate, context: sharedContext)
            mapView.addAnnotation(pinToAdd!)
        case .Changed :
            pinToAdd!.willChangeValueForKey("coordinate")
            pinToAdd!.coordinate = coordinate
            pinToAdd!.didChangeValueForKey("coordinate")
            
            self.sharedContext.performBlockAndWait({
                CoreDataStackManager.sharedInstance().saveContext()
            })
            pinToAdd!.fetchAndStoreImages(nil)
        case .Ended :
            print("Ended pin drop")
            
            /* Wait until coredata saves before fetching photos for the pin */
            self.sharedContext.performBlockAndWait({
                CoreDataStackManager.sharedInstance().saveContext()
            })
            pinToAdd!.fetchAndStoreImages(nil)
        default :
            return
        }
        
    }
    
    
    /* When the fetched results controller changes pins, handle the mapview insertion and deletion */
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
    
    /* Fetched Results controller for Pin entities */
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
    
    /* Convenience for remove and adding all mapview annotations */
    func configureAllAnnotations() {
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(fetchedResultsController.fetchedObjects as! [Pin])
        
    }
    
    @IBAction func didTapEditingUpInside(sender: AnyObject) {
        /* Switch editing state */
        _editing = !_editing
        
        if _editing {
            editButton.title = "Done"
            tapPinsToDeleteBanner.hidden = false
            tapPinsToDeleteBanner.animate()
        } else {
            editButton.title = "Edit"
            tapPinsToDeleteBanner.fadeOut(0.5, delay: 0.0, endAlpha: 0.0, completion: {Void in
                self.tapPinsToDeleteBanner.hidden = true
            })
        }
    }

    
    func savePinAndPrefetchImages(pin: Pin) {
        
        /* save context for the pin */
        self.sharedContext.performBlockAndWait({
            CoreDataStackManager.sharedInstance().saveContext()
        })
        
        /* Defer errors to next view to avoid cluttering up this one */
        pin.fetchAndStoreImages(nil)
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    /* The following three functions save and restore the map stay, helping to persist map annotations between sessions */
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
    
    /* Core data stuff for saving map state */
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

    
}

/* Map view extension methods */
extension PinLocationViewController: MKMapViewDelegate {
    
    /* Save map state when region changes. */
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapState()
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if !editing {
        
        let galleryViewController = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        
        let pin = view.annotation as! Pin
        
        galleryViewController.pinLocation(self, didPickPin: pin)
        
        navigationController?.pushViewController(galleryViewController, animated: true)
        } else {
            /* Delete pins when edit button is toggled */
            let pin = view.annotation as! Pin
            mapView.removeAnnotation(pin)
            CoreDataStackManager.sharedInstance().saveContext()
        }
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
            
            /* If fun mode, then use the Udacity logo */
            if appDelegate.globalSettings?.funMode == true {
                annotationViewToReturn.image = UIImage(named: "udacity-pin-logo")
            } else {
                annotationViewToReturn.image = nil
            }
            return annotationViewToReturn
        }
        return nil
    }
    
}
